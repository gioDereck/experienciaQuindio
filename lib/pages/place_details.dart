import 'dart:convert';
// import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/blocs/bookmark_bloc.dart';
import 'package:travel_hour/blocs/featured_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/blocs/sp_state_one.dart';
import 'package:travel_hour/blocs/sp_state_two.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/comments.dart';
import 'package:travel_hour/pages/guide.dart';
import 'package:travel_hour/services/hash_date_service.dart';
import 'package:travel_hour/services/location_service.dart';
import 'package:travel_hour/services/navigation_service.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/utils/sign_in_dialog.dart';
import 'package:travel_hour/widgets/bookmark_icon.dart';
import 'package:travel_hour/widgets/business_button.dart';
import 'package:travel_hour/widgets/category_icon_widget.dart';
import 'package:travel_hour/widgets/comment_count.dart';
import 'package:travel_hour/widgets/contact_buttons.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/widgets/love_count.dart';
import 'package:travel_hour/widgets/love_icon.dart';
import 'package:travel_hour/widgets/other_places.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/widgets/speech_button.dart';
import 'package:travel_hour/widgets/wheater_card.dart';
import 'package:get/get.dart';
import '../blocs/gps/gps_bloc.dart';
import '../widgets/html_body.dart';
import 'package:translator/translator.dart';
import 'package:html/parser.dart' as html_parser;
// import 'dart:js' as js;
//import '../utils/platfom_web_utils_loader.dart';

class PlaceDetails extends StatefulWidget {
  final Place? data;
  final String? tag;
  final bool itComeFromHome;
  final String? previousRoute;

  const PlaceDetails(
      {Key? key,
      required this.data,
      required this.tag,
      this.itComeFromHome = false,
      this.previousRoute})
      : super(key: key);

  @override
  _PlaceDetailsState createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  final String collectionName = 'places';
  Map<String, dynamic>? weatherData;

  // Variables para la Traducción
  String? translatedDescription;
  bool isTranslationLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500)).then((value) async {
      await _getLocation();
    });
  }

  Future<void> _getLocation() async {
    final hashdateService = HashDateservice();

    // Verifica si la fecha ya esta almacenada
    bool dateExists = await hashdateService.isDateStored();

    if (!dateExists) {
      // Si no existe, almacenar la fecha y el hash
      await hashdateService.storeCurrentDate();
      // consultar la ubicación inmediatamente después de almacenar
      await _consultLocationIfGranted(hashdateService);
    } else {
      // Si ya existe, verificar la diferencia de horas
      bool diffHours =
          await hashdateService.isDifferenceGreaterThan(Config().hoursDiff);

      if (diffHours) {
        // Solo consultar la ubicación si ha pasado el tiempo establecido
        await _consultLocationIfGranted(hashdateService);
      }
    }
  }

  // Método auxiliar para consultar la ubicación si se tienen los permisos necesarios
  Future<void> _consultLocationIfGranted(
      HashDateservice hashdateService) async {
    final GpsBloc gpsBloc = context.read<GpsBloc>(); // Accede al GpsBloc
    //print('State GPS: ${gpsBloc.state.isAllGranted}');
    if (gpsBloc.state.isAllGranted) {
      await gpsBloc.getLocation();

      // Obtener la ubicación guardada
      final location = await LocationService().getSavedLocation();

      if (location != null) {
        double latitude = location['latitude']!;
        double longitude = location['longitude']!;

        // Obtener el hash almacenado
        String? storedHash = await hashdateService.getStoredHash();

        // Preparar los datos para la solicitud POST
        final Map<String, dynamic> requestData = {
          "email": context.read<SignInBloc>().email,
          "hash": storedHash,
          "latitude": latitude,
          "longitude": longitude,
          "name_place": widget.data!.name,
        };

        // Enviar la solicitud POST
        await _sendLocationData(requestData);
      }
    }
  }

  // Método para enviar los datos de ubicación
  Future<void> _sendLocationData(Map<String, dynamic> data) async {
    final url = '${Config().url}/api/location/location-user';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        // Decodificar la respuesta del servidor
        //final Map<String, dynamic> responseBody = json.decode(response.body);

        // Verificar el estado de la respuesta
        // if (responseBody['status'] == 'success') {
        //   print(responseBody['message']);
        // }
      } else {
        print('Error al enviar ubicación: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al enviar ubicación: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener el idioma del contexto
    final String lang = context.locale.languageCode;
    final String? countryCode = context.locale.countryCode;
    String localeTag = countryCode != null ? '$lang-$countryCode' : lang;

    // Llamar al método _fetchWeatherData si no se ha obtenido el clima aún
    if (weatherData == null) {
      _fetchWeatherData(lang);
    }

    // Llamar al método de traducción si aún no se ha traducido
    if (translatedDescription == null) {
      _translateDescription(localeTag);
    }
  }

  // Método para consultar el endpoint y obtener el JSON del clima
  Future<void> _fetchWeatherData(String lang) async {
    // Obtener latitud y longitud del objeto Place
    final double? latitude = widget.data?.latitude;
    final double? longitude = widget.data?.longitude;

    if (latitude == null || longitude == null) {
      //print('Latitud o longitud no disponibles');
      return;
    }

    // Construir la URL usando latitud y longitud
    String apiUrl =
        '${Config().url}/api/wheather/search?lat=$latitude&lon=$longitude&lang=$lang';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        // Manejo de errores
        print('Error al obtener los datos del clima: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al hacer la petición: $e');
    }
  }

  handleLoveClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;
    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onLoveIconClick(collectionName, widget.data!.timestamp);
    }
  }

  handleBookmarkClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;
    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onBookmarkIconClick(collectionName, widget.data!.timestamp);
    }
  }

  // Método para extraer texto limpio de HTML
  String _extractTextFromHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    return html_parser.parse(document.body?.text).documentElement?.text ?? '';
  }

  Future<void> _translateDescription(String lang) async {
    final translator = GoogleTranslator();
    String content = widget.data?.description.toString() ?? '';

    try {
      String plainText = _extractTextFromHtml(content);
      Translation translation = await translator.translate(plainText, to: lang);
      setState(() {
        translatedDescription = translation.text;
        isTranslationLoading = false;
      });
      //print('Descripción traducida: $translatedDescription');
    } catch (e) {
      print('Error en la traducción: $e');
      setState(() {
        translatedDescription =
            _extractTextFromHtml(content); // Fallback al texto original
        isTranslationLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = context.watch<SignInBloc>();
    final _heroTag = GlobalKey().toString();

    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: ContactButtons(
        withoutAssistant: false,
        uniqueId: _heroTag,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                widget.tag == null
                    ? _slidableImages()
                    : Hero(
                        tag: '${widget.tag!}_$_heroTag',
                        child: _slidableImages(),
                      ),
                Positioned(
                  top: 20,
                  left: 15,
                  child: SafeArea(
                    child: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.9),
                      child: IconButton(
                        icon: Icon(
                          LineIcons.arrowLeft,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (widget.itComeFromHome) {
                            context.read<BookmarkBloc>().refreshData();
                            context.read<FeaturedBloc>().onRefresh();
                            context.read<SpecialStateOneBloc>().onRefresh();
                            context.read<SpecialStateTwoBloc>().onRefresh();
                          }
                          // Navigator.pop(context);
                          if (widget.previousRoute != null) {
                            if (widget.previousRoute == 'popular' ||
                                widget.previousRoute == 'recently added' ||
                                widget.previousRoute == 'recommended') {
                              print(widget.previousRoute);

                              nextScreenGoWithExtra(context, 'places', {
                                'title': widget.previousRoute,
                                'color': widget.previousRoute == 'recommended'
                                    ? Colors.green[300]
                                    : Colors.blueGrey[600],
                                'previous_route': 'home'
                              });
                            } else {
                              nextScreenGoNamed(context, widget.previousRoute!);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, bottom: 8, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Expanded(
                          child: Text(
                        widget.data!.location!,
                        style: _textStyleMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      IconButton(
                          icon: BuildLoveIcon(
                              collectionName: collectionName,
                              uid: sb.uid,
                              timestamp: widget.data!.timestamp),
                          onPressed: () {
                            handleLoveClick();
                          }),
                      IconButton(
                          icon: BuildBookmarkIcon(
                              collectionName: collectionName,
                              uid: sb.uid,
                              timestamp: widget.data!.timestamp),
                          onPressed: () {
                            handleBookmarkClick();
                          }),
                      SizedBox(width: 8),
                      InkWell(
                        // Usar InkWell para hacer clickeable el ícono
                        onTap: () => nextScreen(
                          context,
                          CommentsPage(
                            collectionName: 'places',
                            timestamp: widget.data!.timestamp,
                          ),
                        ),
                        child: Icon(
                          Feather.message_circle,
                          color: Colors.black,
                          size: 23,
                        ),
                      ),
                    ],
                  ),
                  Text(widget.data!.name!,
                      style: _textStyleLarge.copyWith(
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.w900),
                          letterSpacing: -0.6,
                          wordSpacing: 1,
                          color: Colors.grey[800])),
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  Row(
                    children: <Widget>[
                      LoveCount(
                          collectionName: collectionName,
                          timestamp: widget.data!.timestamp),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(
                        Feather.message_circle,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      CommentCount(
                          collectionName: collectionName,
                          timestamp: widget.data!.timestamp)
                    ],
                  ),
                ],
              ),
            ),

            // **Agregar el botón de Speak/Stop aquí**
            SpeechButton(
              text: translatedDescription,
              defaultLanguage: 'es-ES',
              speechRate: 0.5,
              pitch: 1.0,
            ),

            // **HtmlBodyWidget existente**
            HtmlBodyWidget(
              content: widget.data!.description.toString(),
              translatedContent: translatedDescription,
              isIframeVideoEnabled: true,
              isVideoEnabled: true,
              isimageEnabled: true,
              fontSize: null,
            ),

            // Weather card agregado aquí
            if (weatherData != null)
              Container(
                width: 480,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: WeatherCard(weatherData: weatherData!),
                ),
              ),

            // Botón "¿Cómo llegar?"
            Center(
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width > 800
                        ? 400
                        : double.infinity),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GuidePage(d: widget.data!)),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD843), // Fondo amarillo
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícono de ubicación morado
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 191, 141, 212),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LineIcons.mapMarker,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'travel guide',
                          style: _textStyleMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ).tr(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // CategoryIconsWidget
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: CategoryIconsWidget(placeData: widget.data),
            ),

            // Allied businesses section
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'allied businesses',
                    style: _textStyleLarge.copyWith(
                      fontWeight: fontSizeController
                          .obtainContrastFromBase(FontWeight.w900),
                      letterSpacing: -0.6,
                      wordSpacing: 1,
                      color: Colors.grey[800],
                    ),
                  ).tr(),
                  SizedBox(height: 4),
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 1200,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return constraints.maxWidth > 1000
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: BusinessButton(
                                        context: context,
                                        color: Color(0xFFFFD843),
                                        icon: Icons.restaurant_menu,
                                        label: 'restaurants delivery',
                                        url:
                                            "https://app.pideylisto.com/allies/2",
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: BusinessButton(
                                        context: context,
                                        color:
                                            Color.fromARGB(255, 191, 141, 212),
                                        icon: Icons.store_mall_directory,
                                        label: 'virtual stores',
                                        url:
                                            "https://app.pideylisto.com/allies/1",
                                      ),
                                    ),
                                    SizedBox(
                                        width: 20), // Espacio entre los botones
                                    Expanded(
                                      child: BusinessButton(
                                        context: context,
                                        color: Color(0xFFA5CE37),
                                        icon: Icons.recycling,
                                        label: 'recycle',
                                        url: "https://www.reciiclaresp.org/",
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BusinessButton(
                                      context: context,
                                      color: Color(0xFFFFD843),
                                      icon: Icons.restaurant_menu,
                                      label: 'restaurants delivery',
                                      url:
                                          "https://app.pideylisto.com/allies/2",
                                    ),
                                    SizedBox(
                                        height: 8), // Espacio entre los botones
                                    BusinessButton(
                                      context: context,
                                      color: Color.fromARGB(255, 191, 141, 212),
                                      icon: Icons.store_mall_directory,
                                      label: 'virtual stores',
                                      url:
                                          "https://app.pideylisto.com/allies/1",
                                    ),
                                    SizedBox(
                                        height: 8), // Espacio entre los botones
                                    BusinessButton(
                                      context: context,
                                      color: Color(0xFFA5CE37),
                                      icon: Icons.recycling,
                                      label: 'recycle',
                                      url: "https://www.reciiclaresp.org/",
                                    ),
                                  ],
                                );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 40),
              child: OtherPlaces(
                stateName: widget.data!.state,
                timestamp: widget.data!.timestamp,
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _slidableImages() {
    return Container(
      color: Colors.white,
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: AnotherCarousel(
            dotBgColor: Colors.transparent,
            showIndicator: true,
            dotSize: 5,
            dotSpacing: 15,
            boxFit: BoxFit.cover,
            images: [
              CustomCacheImage(imageUrl: widget.data!.imageUrl1),
              CustomCacheImage(imageUrl: widget.data!.imageUrl2),
              CustomCacheImage(imageUrl: widget.data!.imageUrl3),
            ]),
      ),
    );
  }

  // Método _buildIconColumn sin cambios
  // Widget _buildIconColumn(Map<String, dynamic> item) {
  //   return InkWell(
  //     onTap: () {
  //       if (item['page'] != null) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => item['page']),
  //         );
  //       }
  //     },
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: item['color'] ?? Colors.grey,
  //             shape: BoxShape.circle,
  //             border: item['color'] == Colors.white
  //                 ? Border.all(color: Colors.black, width: 2)
  //                 : null,
  //           ),
  //           child: Icon(
  //             item['icon'],
  //             color:
  //                 item['color'] == Colors.white ? Colors.black : Colors.white,
  //             size: item['color'] == Colors.white ? 22 : 26,
  //           ),
  //         ),
  //         SizedBox(height: 4),
  //         Text(
  //           item['label'],
  //           textAlign: TextAlign.center,
  //           style: TextStyle(fontSize: 10),
  //         ).tr(),
  //       ],
  //     ),
  //   );
  // }
}
