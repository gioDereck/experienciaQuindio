import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geo/geo.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/models/colors.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/utils/convert_map_icon.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class GuidePage extends StatefulWidget {
  final Place? d;
  GuidePage({Key? key, required this.d}) : super(key: key);

  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  late GoogleMapController mapController;

  List<Marker> _markers = [];
  Map? data = {};
  String distance = 'O km';
  double _distanceInMeters = 0.0;
  bool isLoading = false;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  Uint8List? _sourceIcon;
  Uint8List? _destinationIcon;

  final translator = GoogleTranslator();

  Future getData() async {
    await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.d!.timestamp)
        .collection('travel guide')
        .doc(widget.d!.timestamp)
        .get()
        .then((DocumentSnapshot snap) async {
      data = snap.data() as Map<dynamic, dynamic>?;

      if (data != null && data!['paths'] != null) {
        List<String> paths = List<String>.from(data!['paths']);
        List<String> translatedPaths = [];

        for (String path in paths) {
          try {
            var translation = await translator.translate(path,
                from: 'auto', to: context.locale.languageCode);
            translatedPaths.add(translation.text);
          } catch (error) {
            print('Translation error: $error');
            translatedPaths.add(path);
          }
        }

        setState(() {
          data!['paths'] = translatedPaths;
        });
      }
    });
  }

  Future _setMarkerIcons() async {
    try {
      // Usa assetPath para ajustar las rutas de los íconos
      // _sourceIcon = await getBytesFromAsset('Config().drivingMarkerIcon', 50);

      // Cargar el icono del el recurso local y redimensionarlo
      _sourceIcon = await loadAndResizeImage2(Config().drivingMarkerIcon,
          targetWidth: 60, targetHeight: 60 // Tamaño deseado
          );

      // Cargar el icono del el recurso local y redimensionarlo
      _destinationIcon = await loadAndResizeImage2(
          Config().destinationMarkerIcon,
          targetWidth: 60,
          targetHeight: 60 // Tamaño deseado
          );
    } catch (e) {
      print('Error al cargar los marcadores: $e');
    }
  }

  Future addMarker() async {
    List<Marker> m = [
      Marker(
          markerId: MarkerId(data!['startpoint name']),
          position: LatLng(data!['startpoint lat'], data!['startpoint lng']),
          infoWindow: InfoWindow(title: data!['startpoint name']),
          icon: _sourceIcon != null
              ? BitmapDescriptor.bytes(_sourceIcon!)
              : BitmapDescriptor.defaultMarker),
      Marker(
          markerId: MarkerId(data!['endpoint name']),
          position: LatLng(data!['endpoint lat'], data!['endpoint lng']),
          infoWindow: InfoWindow(title: data!['endpoint name']),
          icon: _destinationIcon != null
              ? BitmapDescriptor.bytes(_destinationIcon!)
              : BitmapDescriptor.defaultMarker)
    ];
    setState(() {
      // m.forEach((element) {
      //   _markers.add(element);
      // });
      _markers.addAll(m); // Usar addAll para simplificar
    });
  }

  Future computeDistance() async {
    var p1 = geo.LatLng(data!['startpoint lat'], data!['startpoint lng']);
    var p2 = geo.LatLng(data!['endpoint lat'], data!['endpoint lng']);
    double _distance = geo.computeDistanceBetween(p1, p2) / 1000;
    setState(() {
      _distanceInMeters = _distance * 1000; // Almacena en metros
      distance = '${_distance.toStringAsFixed(2)} km';
    });
  }

  Future _getPolyline() async {
    if (kIsWeb) {
      final String origin =
          '${data!['startpoint lat']},${data!['startpoint lng']}';
      final String destination =
          '${data!['endpoint lat']},${data!['endpoint lng']}';

      try {
        final response = await http.get(Uri.parse(
            '${Config().url}/api/maps/getPolyline' +
                '?origin=${origin}' +
                '&destination=${destination}'));

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          // Procesa el resultado del API
          if (result['status'] == 'OK') {
            if (result['routes'].isNotEmpty) {
              // Obtener la distancia almacenada en la respuesta
              setState(() {
                distance = result['routes'][0]['legs'][0]['distance']['text'];
                _distanceInMeters =
                    result['routes'][0]['legs'][0]['distance']['value'];
              });

              // Obtener la polilínea codificada
              String encodedPolyline =
                  result['routes'][0]['overview_polyline']['points'];

              // Decodificar los puntos de la polilínea
              List<PointLatLng> points =
                  polylinePoints.decodePolyline(encodedPolyline);

              points.forEach((PointLatLng point) {
                polylineCoordinates
                    .add(LatLng(point.latitude, point.longitude));
              });

              _addPolyLine();
              _centerMapOnRoute();
              animateCamera();
            }
          } else {
            print('Error al obtener la ruta: ${result['status']}');
          }
        } else {
          print('Error en la solicitud: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al trazar la línea: $e');
      }
    } else {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(data!['startpoint lat'], data!['startpoint lng']),
          destination:
              PointLatLng(data!['endpoint lat'], data!['endpoint lng']),
          mode: TravelMode.driving,
        ),
        googleApiKey: Config().mapAPIKey,
      );

      if (result.status == 'OK') {
        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });

          _addPolyLine();

          // Centrar el mapa en la ruta
          _centerMapOnRoute();
          computeDistance();
          animateCamera();
        }
      } else if (result.status == 'ZERO_RESULTS') {
        print('No se encontró una ruta entre los puntos especificados.');
        // Aquí puedes mostrar un diálogo o mensaje al usuario
      } else {
        print('Error al obtener la ruta: ${result.status}');
      }
    }
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Color.fromARGB(255, 40, 122, 198),
        points: polylineCoordinates,
        width: 6);

    polylines[id] = polyline;
    setState(() {});
  }

  void animateCamera() {
    // Obtener las coordenadas de inicio y fin
    double startLat = data!['startpoint lat'];
    double startLng = data!['startpoint lng'];
    double endLat = data!['endpoint lat'];
    double endLng = data!['endpoint lng'];

    // Calcular el punto medio
    double midLat = (startLat + endLat) / 2;
    double midLng = (startLng + endLng) / 2;

    // Ajustar la cámara al punto medio
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(midLat, midLng),
      zoom: _distanceInMeters > 70000
          ? 8
          : 11, // Ajusta el zoom según sea necesario
      bearing: 50, // Puedes ajustar el bearing si es necesario
    )));
  }

  void _centerMapOnRoute() {
    // Crear límites para incluir el origen y el destino
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        data!['startpoint lat'] < data!['endpoint lat']
            ? data!['startpoint lat']
            : data!['endpoint lat'],
        data!['startpoint lng'] < data!['endpoint lng']
            ? data!['startpoint lng']
            : data!['endpoint lng'],
      ),
      northeast: LatLng(
        data!['startpoint lat'] > data!['endpoint lat']
            ? data!['startpoint lat']
            : data!['endpoint lat'],
        data!['startpoint lng'] > data!['endpoint lng']
            ? data!['startpoint lng']
            : data!['endpoint lng'],
      ),
    );

    // Ajustar la cámara para que se ajuste a los límites
    mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50)); // El valor 50 es un padding
  }

  void onMapCreated(controller) {
    //controller.setMapStyle(MapUtils.mapStyles);
    setState(() {
      mapController = controller;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Espera 1 segundo antes de iniciar la carga
    await Future.delayed(Duration(milliseconds: 1500));

    // Carga los íconos, datos y añade los marcadores
    await _setMarkerIcons(); // Espera a que se carguen los íconos
    await getData(); // Espera a que se obtengan los datos
    await addMarker(); // Espera a que se añadan los marcadores

    // Ahora que los marcadores están listos, puedes continuar con otras operaciones
    _getPolyline();
    // computeDistance();
  }

  Widget panelUI() {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              easy.tr("travel guide"),
              style: _textStyleLarge.copyWith(
                fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.w600),
                fontSize: 20,
              ),
            ),
          ],
        ),
        RichText(
          text: TextSpan(
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
                fontWeight: FontWeight.normal),
              text: easy.tr('estimated cost = '),
              children: <TextSpan>[
            TextSpan(
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.bold),
              text: data!['price'])
          ])),
        RichText(
            text: TextSpan(
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 15,
                    fontWeight: FontWeight.normal),
                text: easy.tr('distance = '),
                children: <TextSpan>[
              TextSpan(
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  text: distance)
            ])),
        
        MediaQuery.of(context).size.height < 500 ? SizedBox() 
        :  Container(
          margin: EdgeInsets.only(top: 8, bottom: 8),
          height: 3,
          width: 170,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40)),
        ),

        Container(
            padding: MediaQuery.of(context).size.height < 500 ? 
              EdgeInsets.only(top: 0, left: 15, bottom: 15, right: 15) : EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  easy.tr('steps'),
                  style: _textStyleLarge.copyWith(
                    fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.w600),
                    fontSize: 18
                  ),
                ),
                Container(
                  margin: MediaQuery.of(context).size.height < 500 ? 
                  EdgeInsets.all(0) : EdgeInsets.only(top: 8, bottom: 8),
                  height: 3,
                  width: 70,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(40)),
                ),
              ],
            )),
        Expanded(
          child: data!.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.separated(
                  padding: EdgeInsets.only(bottom: 10),
                  itemCount: data!['paths'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              CircleAvatar(
                                  radius: 15,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      ColorList().guideColors[index]),
                              Container(
                                height: 90,
                                width: 2,
                                color: Colors.black12,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Container(
                            child: Expanded(
                              child: Text(
                                data!['paths'][index],
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: _textStyleMedium.copyWith(
                                  fontWeight: fontSizeController
                                      .obtainContrastFromBase(FontWeight.w500),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox();
                  },
                ),
        ),
      ],
    );
  }

  Widget panelBodyUI(h, w) {
    return Container(
      width: w,
      child: GoogleMap(
        zoomControlsEnabled: true,
        initialCameraPosition: Config().initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) => onMapCreated(controller),
        markers: Set.from(_markers),
        polylines: Set<Polyline>.of(polylines.values),
        compassEnabled: false,
        myLocationEnabled: false,
        zoomGesturesEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();

    return new Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _buildSlidingUpPanel(context, h ,w),
            _buildTopBar(context, fontSizeController),
            data!.isEmpty && polylines.isEmpty
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ]
        ),
      )
    );
  }

  Widget _buildSlidingUpPanel(BuildContext context, h, w) {
    return SlidingUpPanel(
      minHeight: 125,
      maxHeight: MediaQuery.of(context).size.height * (
        MediaQuery.of(context).size.height < 500 ? 0.9 : 0.8 
      ),
      backdropEnabled: true,
      backdropOpacity: 0.2,
      backdropTapClosesPanel: true,
      isDraggable: true,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.grey[400]!, blurRadius: 4, offset: Offset(1, 0))
      ],
      padding: EdgeInsets.only(top: 15, left: 10, bottom: 0, right: 10),
      panel: panelUI(),
      body: panelBodyUI(h, w)
    );
  }

  Widget _buildTopBar(BuildContext context, FontSizeController fontSizeController) {
    return Positioned(
      top: 15,
      left: 10,
      child: Container(
        child: Row(
          children: <Widget>[
            InkWell(
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey[300]!,
                          blurRadius: 10,
                          offset: Offset(3, 3))
                    ]),
                child: Icon(Icons.keyboard_backspace, color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              width: 5,
            ),
            data!.isEmpty
                ? Container()
                : Container(
                    width: MediaQuery.of(context).size.width * 0.80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15, top: 10, bottom: 10, right: 15),
                      child: Text(
                        '${data!['startpoint name']} - ${data!['endpoint name']}',
                        style: TextStyle(
                          fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.w600),
                          fontSize: 16
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
