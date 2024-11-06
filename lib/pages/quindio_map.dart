import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/services/map_service.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:http/http.dart' as http;

class QuindioMap extends StatefulWidget {
  const QuindioMap({Key? key}) : super(key: key);

  @override
  _QuindioMapState createState() => _QuindioMapState();
}

class _QuindioMapState extends State<QuindioMap> {
  late GoogleMapController _controller;
  Set<Polygon> _polygons = {};
  PageController? _pageController;
  int? prevPage;
  List<QuindioPOI> _allPOIs = [];
  List<Marker> _markers = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  // Posición inicial centrada en Armenia
  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(4.5339, -75.6714),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8)
      ..addListener(_onScroll);
    _loadGeoJson();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _loadGeoJson() async {
    try {
      // Cargar el GeoJSON desde los assets
      String geoJsonString =
          await rootBundle.loadString('assets/geojson/quindio.json');
      final Map<String, dynamic> geoJson = json.decode(geoJsonString);

      // Extraer las coordenadas del primer feature (asumiendo que es un polígono)
      final coordinates = geoJson['features'][0]['geometry']['coordinates'][0];
      List<LatLng> polygonCoordinates = [];

      // Convertir las coordenadas del GeoJSON a LatLng
      for (var coord in coordinates) {
        // GeoJSON usa [longitude, latitude]
        polygonCoordinates.add(LatLng(coord[1], coord[0]));
      }

      // Crear el polígono con las coordenadas extraídas
      setState(() {
        _polygons.add(
          Polygon(
            polygonId: PolygonId('quindio'),
            points: polygonCoordinates,
            strokeWidth: 2,
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.15),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading GeoJSON: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchPOIs() async {
    try {
      final url = '${Config().url}/api/historical-sites';
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          final List<QuindioPOI> newPOIs = [];

          for (var poi in data['data']) {
            try {
              final newPOI = QuindioPOI(
                  name: poi['name'] ?? 'Sin nombre',
                  category: poi['classification'] ?? 'Sin categoría',
                  lat: double.tryParse(poi['latitude']?.toString() ?? '0') ?? 0,
                  lng:
                      double.tryParse(poi['longitude']?.toString() ?? '0') ?? 0,
                  description: poi['description'] ?? 'Sin descripción',
                  rating: double.tryParse(poi['score']?.toString() ?? '0') ?? 0,
                  photoUrl:
                      poi['image_url'] ?? 'https://via.placeholder.com/150',
                  address: poi['city'] ?? 'Dirección no disponible');

              if (newPOI.lat != 0 && newPOI.lng != 0) {
                newPOIs.add(newPOI);
              }
            } catch (e) {
              print('Error processing individual POI: $e');
            }
          }

          setState(() {
            _allPOIs = newPOIs;
            _markers.clear();

            for (int i = 0; i < _allPOIs.length; i++) {
              final poi = _allPOIs[i];
              _markers.add(
                Marker(
                  markerId: MarkerId(poi.name),
                  position: LatLng(poi.lat, poi.lng),
                  infoWindow: InfoWindow(
                    title: poi.name,
                    snippet: poi.description.substring(0, 70) + '...',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                  onTap: () {
                    _pageController?.animateToPage(
                      i,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              );
            }
          });
        }
      } else {
        print('Error status code: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching historical sites: $e');
    }
  }

  _loadData() async {
    setState(() => _isLoading = true);
    await fetchPOIs();
    setState(() => _isLoading = false);
  }

  void _onScroll() {
    if (_pageController!.page!.toInt() != prevPage) {
      prevPage = _pageController!.page!.toInt();
      moveCamera();
    }
  }

  void moveCamera() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_allPOIs[_pageController!.page!.toInt()].lat,
          _allPOIs[_pageController!.page!.toInt()].lng),
      zoom: 18.0,
      bearing: 45.0,
      tilt: 45.0,
    )));
  }

  Widget _buildPOICard(int index) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return AnimatedBuilder(
      animation: _pageController!,
      builder: (BuildContext context, Widget? widget) {
        double value = 1;
        if (_pageController!.position.haveDimensions) {
          value = _pageController!.page! - index;
          value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 140.0,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: widget,
          ),
        );
      },
      child: InkWell(
        onTap: () => _showPOIModal(index),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 5,
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 10),
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(_allPOIs[index].photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _allPOIs[index].name,
                      style: _textStyleMedium.copyWith(
                        fontWeight: fontSizeController
                            .obtainContrastFromBase(FontWeight.w600),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      _allPOIs[index].address,
                      style: _textStyleMedium.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 5),
                        Text(
                          _allPOIs[index].rating.toString(),
                          style: _textStyleMedium.copyWith(
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPOIModal(int index) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(15)),
                        child: CachedNetworkImage(
                          imageUrl: _allPOIs[index].photoUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _allPOIs[index].name,
                          style: _textStyleLarge.copyWith(
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w600),
                          ),
                        ),
                        SizedBox(height: 15),
                        _buildInfoRow(
                          Icons.location_on,
                          _allPOIs[index].address,
                          _textStyleMedium,
                          fontSizeController,
                        ),
                        _buildInfoRow(
                          Icons.category,
                          _allPOIs[index].category,
                          _textStyleMedium,
                          fontSizeController,
                        ),
                        _buildInfoRow(
                          Icons.star,
                          '${_allPOIs[index].rating}/10',
                          _textStyleMedium,
                          fontSizeController,
                        ),
                        SizedBox(height: 20),
                        Text(
                          _allPOIs[index].description,
                          style: _textStyleMedium,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(LineIcons.directions),
                              label: Text(easy.tr('get directions')),
                              onPressed: () => MapService.openMap(
                                _allPOIs[index].lat,
                                _allPOIs[index].lng,
                                '',
                                context,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text, TextStyle baseStyle,
      FontSizeController fontSizeController) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: baseStyle.copyWith(
                fontWeight:
                    fontSizeController.obtainContrastFromBase(FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('discover quindio').tr(),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialPosition,
                  polygons: _polygons,
                  markers: Set.from(_markers),
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                ),
                Positioned(
                  bottom: 20,
                  child: Container(
                    height: 160,
                    width: MediaQuery.of(context).size.width,
                    child: Listener(
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          final double scrollDelta =
                              pointerSignal.scrollDelta.dy.clamp(-50.0, 50.0);
                          final double newPage = (_pageController!.page ?? 0) +
                              (scrollDelta / 100);

                          if (newPage >= 0 && newPage < _allPOIs.length) {
                            _pageController!.animateToPage(
                              newPage.round(),
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        }
                      },
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _allPOIs.length,
                          itemBuilder: (context, index) => _buildPOICard(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class QuindioPOI {
  final String name;
  final String address;
  final String description;
  final String photoUrl;
  final double rating;
  final double lat;
  final double lng;
  final String category;

  QuindioPOI({
    required this.name,
    required this.address,
    required this.description,
    required this.photoUrl,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.category,
  });
}
