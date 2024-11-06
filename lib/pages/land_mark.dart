import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/models/land_mark.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/services/map_service.dart';
import 'package:travel_hour/utils/convert_map_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class LandmarkPage extends StatefulWidget {
  final Place? placeData;
  final String site;
  final String? radius;
  final String? type;
  final String? keyword;
  final double zoom;

  LandmarkPage(
    {
      Key? key,
      required this.placeData,
      this.site = '',
      this.radius,
      this.type,
      this.keyword,
      this.zoom = 13,
    })
    : super(key: key);

  _LandmarkPageState createState() => _LandmarkPageState();
}

class _LandmarkPageState extends State<LandmarkPage> {
  late GoogleMapController _controller;
  List<LandMark> _alldata = [];
  PageController? _pageController;
  int? prevPage;
  List _markers = [];
  Uint8List? _customMarkerIcon;
  bool _isScrolling = false;
  bool isLoading = false;
  DateTime _lastScrollTime = DateTime.now();
  static const _scrollThreshold = 50.0;
  static const _scrollCooldown = Duration(milliseconds: 200);

  void openEmptyDialog() {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: Text(
                  easy.tr(
                      "we didn't find any nearby ${widget.site} in this area"),
                  style: _textStyleMedium),
              title: Text(
                easy.tr('no ${widget.site} found'),
                style: _textStyleMedium.copyWith(
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.w700)),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text('OK', style: _textStyleMedium))
              ],
            ),
          );
        });
  }

  Future getData() async {
    http.Response response;

    //Condicionalmente agrega el tipo si está definido
    String typeParam = widget.type != null && widget.type!.isNotEmpty
        ? '&type=${widget.type}'
        : '';

    if (kIsWeb) {
      response = await http.get(Uri.parse('${Config().url}/api/maps/nearby-search' +
        '?location=${widget.placeData!.latitude},${widget.placeData!.longitude}' +
        '&radius=${widget.radius ?? 3000}' + 
        //'&bounds=${widget.southCord},${widget.westCord}|${widget.northCoord},${widget.eastCord}' +
        '${typeParam}' +
        '&keyword=${widget.keyword}'));
    } else {
      response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json' +
          '?location=${widget.placeData!.latitude},${widget.placeData!.longitude}' +
          '&radius=${widget.radius ?? 3000}' + 
          //'&bounds=${widget.southCord},${widget.westCord}|${widget.northCoord},${widget.eastCord}' +
          '${typeParam}' +
          '&keyword=${widget.keyword}' +
          '&key=${Config().mapAPIKey}'));
    }

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      final List _rawData = decodedData['results'];
      if (_rawData.isEmpty) {
        openEmptyDialog();
      } else {
        _alldata = _rawData.map((m) => LandMark.fromJson(m)).toList();
        _alldata.sort((a, b) => b.rating.compareTo(a.rating));
      }
    }
  }

  Future<void> _addMarker() async {
    for (var data in _alldata) {
      final bool isInPolygon = await isPointInPolygon(data);
      if (isInPolygon) {
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(data.name!),
            position: LatLng(data.lat!, data.lng!),
            infoWindow: InfoWindow(title: data.name, snippet: data.address),
            icon: _customMarkerIcon != null
                ? BitmapDescriptor.bytes(_customMarkerIcon!)
                : BitmapDescriptor.defaultMarker,
            onTap: () {
              int selectedIndex =
                  _alldata.indexWhere((item) => item.name == data.name);
              if (selectedIndex != -1) {
                String photoUrl = data.photoReference != null
                    ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${data.photoReference}&key=${Config().mapAPIKey}'
                    : Config.emptyImage;
                _jumpToCard(selectedIndex, photoUrl);
              }
            },
          ));
        });
      }
    }
    
    // Filtrar _alldata
    List<LandMark> filteredData = [];
    for (var data in _alldata) {
      if (await isPointInPolygon(data)) {
        filteredData.add(data);
      }
    }
    setState(() {
      _alldata = filteredData;
    });
  }

  List<double> parseCoordinates(String coords) {
    return coords
      .split(',')
      .map((e) => double.parse(e.trim()))
      .toList();
  }

  Future<Map<String, dynamic>?> getStateCoordinates(String stateName) async {
    try {
      final QuerySnapshot stateDoc = await FirebaseFirestore.instance
          .collection('places')
          .where('place name', isEqualTo: stateName)
          .where('isState', isEqualTo: true)
          .limit(1)
          .get();

      if (stateDoc.docs.isNotEmpty) {
        return stateDoc.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting state coordinates: $e');
      return null;
    }
  }

  Future<bool> isPointInPolygon(LandMark data) async {
    String? northCoord;
    String? southCoord;
    String? eastCoord;
    String? westCoord;

    // Si el placeData actual es un estado o ya tiene coordenadas, úsalas directamente
    if (!widget.placeData!.isState! && 
        (widget.placeData?.northCoord == null || 
        widget.placeData?.southCoord == null || 
        widget.placeData?.eastCoord == null || 
        widget.placeData?.westCoord == null)) {
      
      // Buscar las coordenadas del estado
      if (widget.placeData?.state != null) {
        final stateData = await getStateCoordinates(widget.placeData!.state!);
        if (stateData != null) {
          northCoord = stateData['northCoord'];
          southCoord = stateData['southCoord'];
          eastCoord = stateData['eastCoord'];
          westCoord = stateData['westCoord'];
        }
      }
    } else {
      // Usar las coordenadas del placeData actual
      northCoord = widget.placeData?.northCoord;
      southCoord = widget.placeData?.southCoord;
      eastCoord = widget.placeData?.eastCoord;
      westCoord = widget.placeData?.westCoord;
    }

    // Si no se encontraron coordenadas en ningún caso, retornar true para incluir el punto
    if (northCoord == null || southCoord == null || 
        eastCoord == null || westCoord == null) {
      return true;
    }

    // Crear el polígono con las coordenadas
    List<List<double>> polygon = [
      parseCoordinates(northCoord),
      parseCoordinates(eastCoord),
      parseCoordinates(southCoord),
      parseCoordinates(westCoord),
    ];

    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i][1] > data.lng!) != (polygon[j][1] > data.lng!) &&
          (data.lat! < (polygon[j][0] - polygon[i][0]) * (data.lng! - polygon[i][1]) /
                  (polygon[j][1] - polygon[i][1]) +
              polygon[i][0])) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  void openGoogleTravel(String placeName, String siteType) async {
    final String url =
        'https://www.google.com/travel/search?q=${Uri.encodeComponent(placeName)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  setMarkerIcon() async {
    String pinIcon;

    // Determinar el ícono según el valor de site
    if (widget.site == 'airport') {
      pinIcon = Config().airportPinIcon;
    } else if (widget.site == 'attractions') {
      pinIcon = Config().attractionPinIcon;
    } else if (widget.site == 'atms') {
      pinIcon = Config().atmPinIcon;
    } else if (widget.site == 'events') {
      pinIcon = Config().eventPinIcon;
    } else if (widget.site == 'gas station') {
      pinIcon = Config().gasStationPinIcon;
    } else if (widget.site == 'hospital') {
      pinIcon = Config().hospitallPinIcon;
    } else if (widget.site == 'hotels') {
      pinIcon = Config().hotelPinIcon;
    } else if (widget.site == 'museums') {
      pinIcon = Config().museumPinIcon;
    } else if (widget.site == 'parkings') {
      pinIcon = Config().parkingPinIcon;
    } else if (widget.site == 'restaurants') {
      pinIcon = Config().restaurantPinIcon;
    } else if (widget.site == 'tourism') {
      pinIcon = Config().touristPinIcon;
    } else if (widget.site == 'exchange_houses') {
      pinIcon = Config().exchangeHousesPinIcon;
    } else if (widget.site == 'shopping_mall') {
      pinIcon = Config().shoppingMallPinIcon;
    } else {
      // Ícono predeterminado si no coincide con ninguno
      pinIcon = Config().pointMarkerIcon2;
    }

    // Usar marcador predeterminado para movil
    // _customMarkerIcon = await getBytesFromAsset(pinIcon, 50);

    // Cargar el icono del el recurso local y redimensionarlo
    _customMarkerIcon =
        await loadAndResizeImage2(pinIcon, targetWidth: 60, targetHeight: 60);
  }

  void _onScroll() {
    if (_pageController!.page!.toInt() != prevPage) {
      prevPage = _pageController!.page!.toInt();
      moveCamera(); // Siempre aplicar zoom al scrollear
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
      ..addListener(_onScroll);
    
    setMarkerIcon();
    getData().then((value) async {
      await _addMarker();
    });
  }

  _landmarkList(index) {
    final String _photoUrl = _alldata[index].photoReference != null
        ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${_alldata[index].photoReference}&key=${Config().mapAPIKey}'
        : Config.emptyImage;

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
          onTap: () => _onCardTap(index, _photoUrl),
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.grey[300]!, blurRadius: 5)
                ]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.all(15),
                  height: MediaQuery.of(context).size.height,
                  width: 110,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Colors.grey[500]!),
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(_photoUrl),
                          fit: BoxFit.cover)),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 10),
                      Text(
                        _alldata[index].name!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _textStyleMedium.copyWith(
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w600)),
                      ),
                      Text(
                        _alldata[index].address!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _textStyleMedium.copyWith(
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w400),
                            color: Colors.blueGrey[600]),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 20,
                            width: 90,
                            child: ListView.builder(
                              itemCount: _alldata[index].rating.round(),
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Icon(LineIcons.starAlt,
                                    color: Colors.orangeAccent, size: 16);
                              },
                            ),
                          ),
                          SizedBox(width: 2),
                          Text(
                            '(${_alldata[index].rating})',
                            style: _textStyleMedium.copyWith(
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w500)),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void _jumpToCard(int index, String photoUrl) {
    // Saltar directamente al índice
    _pageController?.jumpToPage(index);

    // Actualizar la cámara con animación
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_alldata[index].lat!, _alldata[index].lng!),
          zoom: 18.0,
          bearing: 45.0,
          tilt: 45.0,
        ),
      ),
    );
  }

  _onCardTap(index, _photoUrl) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              width: double.infinity,
              child: SingleChildScrollView(
                // Agregamos SingleChildScrollView aquí
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Importante para que la Column no intente ocupar todo el espacio
                  children: <Widget>[
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 15, top: 10, right: 5),
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(_photoUrl),
                                  fit: BoxFit.cover)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: CircleAvatar(
                                  child: Icon(Icons.close),
                                ),
                              ),
                              onTap: () => Navigator.pop(context)),
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15, left: 15, right: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _alldata[index].name!,
                            style: _textStyleLarge.copyWith(
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w600)),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: <Widget>[
                              Icon(Icons.location_on,
                                  color: Colors.orangeAccent, size: 25),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _alldata[index].address!,
                                  style: _textStyleMedium.copyWith(
                                      fontWeight: fontSizeController
                                          .obtainContrastFromBase(
                                              FontWeight.w500)),
                                ),
                              )
                            ],
                          ),
                          Divider(),
                          Row(
                            children: <Widget>[
                              Icon(Icons.star,
                                  color: Colors.orangeAccent, size: 25),
                              SizedBox(width: 10),
                              Text(
                                '${easy.tr('Rating')} : ${_alldata[index].rating}/5',
                                style: _textStyleMedium.copyWith(
                                    fontWeight: fontSizeController
                                        .obtainContrastFromBase(
                                            FontWeight.w500)),
                              )
                            ],
                          ),
                          Divider(),
                          Row(
                            children: <Widget>[
                              Icon(Icons.opacity,
                                  color: Colors.orangeAccent, size: 25),
                              SizedBox(width: 10),
                              _getRating(index)
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height:
                            20), // Espacio adicional para separar los botones
                    Padding(
                      padding: const EdgeInsets.only(right: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                padding: EdgeInsets.all(10)),
                            icon:
                                Icon(LineIcons.directions, color: Colors.white),
                            label: Text(
                              easy.tr('get directions'),
                              style: _textStyleMedium.copyWith(
                                  color: Colors.white),
                            ),
                            onPressed: () => MapService.openMap(
                                _alldata[index].lat!,
                                _alldata[index].lng!,
                                _alldata[index].placeId!,
                                context),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                padding: EdgeInsets.all(10)),
                            icon:
                                Icon(Icons.travel_explore, color: Colors.white),
                            label: Text(easy.tr('more Info'),
                                style: _textStyleMedium.copyWith(
                                    color: Colors.white)),
                            onPressed: () => openGoogleTravel(
                                _alldata[index].name!, widget.site),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Expanded _getRating(index) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    // TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    // TextStyle _textStyleTiny = Theme.of(context).textTheme.bodySmall!;

    String labelPrice = easy.tr('price');
    return Expanded(
        child: Text(
      _alldata[index].price == 0
          ? '${labelPrice} : ${easy.tr('Moderate')}'
          : _alldata[index].price == 1
              ? '${labelPrice} : ${easy.tr('Inexpensive')}'
              : _alldata[index].price == 2
                  ? '${labelPrice} : ${easy.tr('Moderate')}'
                  : _alldata[index].price == 3
                      ? '${labelPrice} : ${easy.tr('Expensive')}'
                      : '${labelPrice} : ${easy.tr('Very Expensive')}',
      style: _textStyleMedium.copyWith(
          fontWeight:
              fontSizeController.obtainContrastFromBase(FontWeight.w500)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                compassEnabled: false,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: Config().initialCameraPosition,
                markers: Set.from(_markers),
                onMapCreated: mapCreated,
              ),
            ),
            _alldata.isEmpty
                ? Container()
                : Positioned(
                    bottom: 10.0,
                    child: Container(
                      height: 200.0,
                      width: MediaQuery.of(context).size.width,
                      child: Listener(
                        onPointerSignal: (PointerSignalEvent event) {
                          if (event is PointerScrollEvent) {
                            final now = DateTime.now();
                            if (now.difference(_lastScrollTime) <
                                _scrollCooldown) {
                              return;
                            }

                            if (!_isScrolling && _pageController != null) {
                              setState(() {
                                _isScrolling = true;
                              });

                              // Manejar el scroll y aplicar zoom
                              if (event.scrollDelta.dy > _scrollThreshold) {
                                if (_pageController!.page! > 0) {
                                  _pageController!
                                      .previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      )
                                      .then((_) => moveCamera());
                                }
                              } else if (event.scrollDelta.dy <
                                  -_scrollThreshold) {
                                if (_pageController!.page! <
                                    _alldata.length - 1) {
                                  _pageController!
                                      .nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      )
                                      .then((_) => moveCamera());
                                }
                              }

                              _lastScrollTime = now;

                              Future.delayed(_scrollCooldown, () {
                                if (mounted) {
                                  setState(() {
                                    _isScrolling = false;
                                  });
                                }
                              });
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
                            itemCount: _alldata.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _landmarkList(index);
                            },
                            onPageChanged: (index) {
                              // Solo actualizar la cámara cuando cambia la página
                              moveCamera();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
            Positioned(
                top: 15,
                left: 10,
                child: Row(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[300]!,
                                  blurRadius: 10,
                                  offset: Offset(3, 3))
                            ]),
                        child: isLoading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3.0,
                              )
                            : Icon(Icons.keyboard_backspace,
                                color: Colors.white),
                      ),
                      onTap: () {
                        if (!isLoading) {
                          setState(() {
                            isLoading = true;
                          });
                          // Cierra la vista y luego cambia el estado de isLoading
                          Navigator.pop(context);
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey, width: 0.5)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 10, bottom: 10, right: 15),
                        child: Text(
                          '${widget.placeData!.name} - ${easy.tr('nearby ${widget.site}')}',
                          style: _textStyleMedium.copyWith(
                              fontWeight: fontSizeController
                                  .obtainContrastFromBase(FontWeight.w600)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                )),
            _alldata.isEmpty
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void mapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
    animateCameraAfterInitialization();
  }

  void animateCameraAfterInitialization() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(widget.placeData!.latitude!, widget.placeData!.longitude!),
      zoom: widget.zoom,
    )));
  }

  void moveCamera() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_alldata[_pageController!.page!.toInt()].lat!,
          _alldata[_pageController!.page!.toInt()].lng!),
      zoom: 18.0,
      bearing: 45.0,
      tilt: 45.0,
    )));
  }
}
