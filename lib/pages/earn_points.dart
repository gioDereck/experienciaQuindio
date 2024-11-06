import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/pages/qr_code.dart';
import 'package:travel_hour/services/map_service.dart';
import 'package:travel_hour/utils/app_colors.dart';
import 'package:travel_hour/utils/convert_map_icon.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:travel_hour/widgets/top_bar_earn_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart' as easy;

class EarnPointsPage extends StatefulWidget {
  EarnPointsPage({Key? key}) : super(key: key);

  _EarnPointsState createState() => _EarnPointsState();
}

class _EarnPointsState extends State<EarnPointsPage> {
  late GoogleMapController mapController;
  List<Marker> _markers = [];
  String distance = 'O km';
  int actualPoints = 0;
  bool showCard = false;
  Uint8List? _destinationIcon;
  Map<String, dynamic>? selectedMarkerData;
  int totalPoints = 0;
  int currentPoints = 0;
  List<CityBadge> badges = [];
  List<MarkerData> markerDetails = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      _showWelcomeModal();
    });
    _loadData();
  }

  _loadData() async {
    await fetchPersonalPoints();
    await fetchMarkerData();
  }

  @override
  void dispose() {
    super.dispose();
    currentPoints = 0;
    badges = [];
    markerDetails = [];
  }

  Future<void> fetchPersonalPoints() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      final email = sp.getString('email');
      if (email == null || email.isEmpty) return;

      final url = '${Config().url}/api/collectible-destinations?email=$email';
      final headers = {
        'Authorization': 'Bearer ' + Config().token,
      };

      final response = await http.get(Uri.parse(url), headers: headers);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] != null) {
          setState(() {
            currentPoints = data['message']['currentPoints'] ?? 0;
            badges = (data['message']['badges'] as List?)
                    ?.map((badge) => CityBadge(
                          name: badge['name'] ?? '',
                          image: badge['image'] ?? '',
                        ))
                    .toList() ??
                [];
          });
        }
      }
    } catch (e) {
      print('Error fetching personal points: $e');
    }
  }

  Future<void> fetchMarkerData() async {
    try {
      final url = '${Config().url}/api/qr-points';
      final headers = {
        'Authorization': 'Bearer ' + Config().token,
      };

      final response = await http.get(Uri.parse(url), headers: headers);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message']?['qrPoints'] != null) {
          List<MarkerData> markerDetailsData = [];

          for (var point in data['message']['qrPoints']) {
            markerDetailsData.add(MarkerData(
              displayName: point['displayName'] ?? '',
              name: point['name'] ?? '',
              address: "Cra. 13 #23-45, Armenia",
              photoUrl: point['photoUrl'] ?? '',
              points: point['points'] ?? 0,
              latitude: double.tryParse(point['lat'] ?? '0') ?? 0,
              longitude: double.tryParse(point['long'] ?? '0') ?? 0,
              placeId: '',
            ));
          }

          setState(() {
            markerDetails = markerDetailsData;
            totalPoints =
                markerDetails.fold(0, (sum, marker) => sum + marker.points);
          });

          await _setMarkerIcons();
          await addMarkers();
        }
      }
    } catch (e) {
      print('Error fetching marker data: $e');
    }
  }

  void _showWelcomeModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            //width: double.infinity, // Ocupar el 100% del ancho
            //height: MediaQuery.of(context).size.height * 0.5, // 70% de la altura de la pantalla
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    top: 30,
                    right: 10,
                    bottom: 10.0,
                  ),
                  child: Image.network(
                    (context.locale.languageCode == 'en'
                        ? '${Config().media_url}/uploads/2024/09/game/gameqr_english.png'
                        : context.locale.languageCode == 'fr'
                            ? '${Config().media_url}/uploads/2024/09/game/gameqr_frances.png'
                            : '${Config().media_url}/uploads/2024/09/game/gameqr.png'),
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return Center(
                          child: Text(
                              'Error al cargar la imagen')); // Manejo de errores.
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _onMarkerTapped(MarkerId markerId, int index) {
    setState(() {
      showCard = true;
      selectedMarkerData = {
        'index': index,
        'details': markerDetails[index],
      };
    });
  }

  Future _setMarkerIcons() async {
    _destinationIcon = await loadAndResizeImage(
      Config().pointMarkerIcon2,
      30,
      40,
    );
  }

  void _closeCard() {
    setState(() {
      showCard = false;
      selectedMarkerData = null;
    });
  }

  void openGoogleTravel(String placeName) async {
    final String url =
        'https://www.google.com/travel/search?q=${Uri.encodeComponent(placeName)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> addMarkers() async {
    List<Marker> markers = markerDetails.asMap().entries.map((entry) {
      int index = entry.key;
      MarkerData markerData = entry.value;

      return Marker(
        markerId:
            MarkerId('marker_${markerData.latitude}_${markerData.longitude}'),
        position: LatLng(markerData.latitude, markerData.longitude),
        icon: _destinationIcon != null
            ? BitmapDescriptor.bytes(_destinationIcon!)
            : BitmapDescriptor.defaultMarker,
        onTap: () {
          _onMarkerTapped(
            MarkerId('marker_${markerData.latitude}_${markerData.longitude}'),
            index,
          );
        },
      );
    }).toList();

    setState(() {
      _markers = markers;
    });
  }

  _onCardTap(index, _photoUrl) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    MarkerData data = selectedMarkerData?['details'];

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.80,
              ),
              width: double.infinity,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: [
                            Container(
                              padding:
                                  EdgeInsets.only(left: 0, top: 0, right: 0),
                              height: 200,
                              width: double.infinity,
                              color: Colors.orangeAccent,
                              child: Image.network(
                                "${Config().media_url}${data.photoUrl}",
                                fit: BoxFit.cover,
                              ),
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
                                onTap: () => Navigator.pop(context),
                              ),
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15, left: 15, right: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                data.displayName,
                                style: _textStyleLarge.copyWith(
                                  fontWeight: fontSizeController
                                      .obtainContrastFromBase(FontWeight.w600),
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.orangeAccent,
                                    size: 25,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      data.address,
                                      style: _textStyleMedium.copyWith(
                                        fontWeight: fontSizeController
                                            .obtainContrastFromBase(
                                                FontWeight.w500),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: Colors.orangeAccent,
                                    size: 25,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '${easy.tr('points_only_capital')} : ${data.points}',
                                    style: _textStyleMedium.copyWith(
                                      fontWeight: fontSizeController
                                          .obtainContrastFromBase(
                                              FontWeight.w500),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 80), // Space for bottom buttons
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: Row(
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: CustomColors.primaryColor,
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                          icon: Icon(
                            LineIcons.qrcode,
                            color: CustomColors.primaryColor,
                          ),
                          label: Text(
                            'scan qr',
                            style: _textStyleMedium.copyWith(
                                color: CustomColors.primaryColor),
                          ).tr(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QrCodePage()),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                          icon: Icon(
                            LineIcons.directions,
                            color: Colors.white,
                          ),
                          label: Text(
                            'get directions',
                            style:
                                _textStyleMedium.copyWith(color: Colors.white),
                          ).tr(),
                          onPressed: () => MapService.openMap(
                            data.latitude,
                            data.longitude,
                            data.placeId,
                            context,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildMarkerCard() {
    if (!showCard || selectedMarkerData == null) return Container();

    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    MarkerData details = selectedMarkerData!['details'];
    int index = selectedMarkerData!['index'];

    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botón de cerrar
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: _closeCard,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(CircleBorder()),
            ),
          ),
          // Tarjeta principal
          InkWell(
            onTap: () => _onCardTap(index, details.photoUrl),
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.grey[300]!, blurRadius: 5)
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    height: 120,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "${Config().media_url}${details.photoUrl}",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Wrap(
                      children: [
                        Container(height: 10),
                        Text(
                          details.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _textStyleMedium.copyWith(
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w600),
                          ),
                        ),
                        Container(height: 10),
                        Text(
                          details.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _textStyleMedium.copyWith(
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w400),
                            color: Colors.blueGrey[600],
                          ),
                        ),
                        Divider(height: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${details.points} : ${easy.tr('points_only_capital')}',
                            style: _textStyleMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });

    _setMarkerIcons().then((value) => addMarkers()).then((value) {
      if (markerDetails.isNotEmpty) {
        // Centrar el mapa en el primer marcador
        /*
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                markerDetails[0].latitude,
                markerDetails[0].longitude,
              ),
              zoom: 8,
            ),
          ),
        );
        */
      }
    }).catchError((error) {
      print('Error al configurar el mapa: $error');
    });
  }

  Widget panelBodyUI(h, w) {
    return Container(
      width: w,
      child: GoogleMap(
        zoomControlsEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(4.639817924432168, -75.56641933109294),
          zoom: 9,
        ),
        mapType: MapType.normal,
        onMapCreated: onMapCreated,
        markers: Set.from(_markers),
        compassEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomGesturesEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TopBarEarnPoints(
              key: ValueKey('earnPointsTopBar'),
              badges: badges,
              currentPoints: currentPoints,
              totalPoints: totalPoints,
              heroTagPrefix: 'earnPoints_',
            ),
            Expanded(
              child: Stack(
                children: [
                  panelBodyUI(h, w),
                  _buildMarkerCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarkerData {
  final String displayName;
  final String name;
  final String address;
  final String photoUrl;
  final int points;
  final double latitude;
  final double longitude;
  final String placeId;

  MarkerData(
      {required this.displayName,
      required this.name,
      required this.address,
      required this.photoUrl,
      required this.points,
      required this.latitude,
      required this.longitude,
      required this.placeId});
}

class CityBadge {
  final String name;
  final String image;

  CityBadge({required this.name, required this.image});

  factory CityBadge.fromJson(Map<String, dynamic> json) {
    return CityBadge(
      name: json['name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }
}
