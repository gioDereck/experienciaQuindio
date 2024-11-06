import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:travel_hour/blocs/gps/gps_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/pages/done.dart';
import 'package:travel_hour/services/platform_detection_service.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/utils/snacbar.dart';
import 'package:travel_hour/widgets/language.dart';
// import 'package:travel_hour/services/location_service.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class SignInPage extends StatefulWidget {
  final String? tag;
  SignInPage({Key? key, this.tag}) : super(key: key);

  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool googleSignInStarted = false;
  bool facebookSignInStarted = false;
  bool appleSignInStarted = false;

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _evaluateLocation() async {
  //   final savedLocation = await LocationService().getSavedLocation();
  //   if (savedLocation != null) {
  //     print(
  //         'Ubicación guardada - Latitud: ${savedLocation['latitude']}, Longitud: ${savedLocation['longitude']}');
  //   }
  // }

  void _showNoLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ubicación no disponible'),
          content: Text(
              'No se pudo obtener la ubicación. Por favor, habilita los permisos de ubicación manualmente.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor),
              child: Text('Aceptar', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Método handleSkip añadido aquí
  void handleSkip() {
    final sb = context.read<SignInBloc>();
    sb.setGuestUser();
    nextScreen(context, DonePage());
  }

  void handleGoogleSignIn() async {
    final sb = context.read<SignInBloc>();
    setState(() => googleSignInStarted = true);

    await sb.signInWithGoogle().then((_) {
      if (sb.hasError == true) {
        openSnacbar(context, easy.tr('something is wrong. please try again.'));
        setState(() => googleSignInStarted = false);
      } else {
        sb.checkUserExists().then((value) {
          if (value == true) {
            sb.getUserDatafromFirebase(sb.uid).then((value) => sb
                .saveDataToSP()
                .then((value) => sb.guestSignout())
                .then((value) => sb.setSignIn().then((value) {
                      setState(() => googleSignInStarted = false);
                      afterSignIn();
                    })));
          } else {
            sb.getJoiningDate().then((value) => sb
                .saveToFirebase()
                .then((value) => sb.increaseUserCount())
                .then((value) => sb.saveDataToSP().then((value) => sb
                    .guestSignout()
                    .then((value) => sb.setSignIn().then((value) {
                          setState(() => googleSignInStarted = false);
                          afterSignIn();
                        })))));
          }
        });
      }
    });
  }

  void afterSignIn() {
    if (widget.tag == null) {
      nextScreen(context, DonePage());
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    String systemLanguage = easy.Intl.systemLocale;
    String languageCode = systemLanguage.substring(0, 2);
    if (languageCode != "en" && languageCode != "es" && languageCode != "fr") {
      languageCode = "en";
    }
    // context.setLocale(Locale(languageCode));

    final platformService = PlatformDetectionService();
    // Determinar si estamos en móvil y la orientación
    return ListenableBuilder(
      listenable: platformService,
      builder: (context, child) {
        final bool isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;

        // Información detallada del dispositivo
        final deviceInfo = platformService.getDeviceInfo();

        // Altura y ancho total de la pantalla
        final screenHeight = deviceInfo['screenHeight'];
        final screenWidth = deviceInfo['screenWidth'];

        final isMobile = platformService.isMobileWeb;

        // Calcular el ancho del contenedor principal
        // final containerWidth = isMobile ? screenWidth : 1024.0;
        final containerWidth = screenWidth;

        // Calcular espacio entre el logo y el boton
        final spaceBetween = isMobile
            ? (isPortrait
                ? 70.0
                : 30.0) // Móvil: 70 en portrait, 30 en landscape
            : 100.0;

        // Calcular el ancho del botón
        final buttonWidth = isMobile
            ? (isPortrait ? containerWidth * 0.45 : containerWidth * 0.25)
            : containerWidth * 0.25;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: containerWidth),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.tag == null)
                      TextButton(
                        onPressed: () => handleGoogleSignIn(),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.transparent),
                        ),
                        child: googleSignInStarted
                            ? Center(
                                child: CircularProgressIndicator(
                                    backgroundColor: Colors.white),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(FontAwesome.google, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'Sign In with Google',
                                    style: _textStyleMedium.copyWith(
                                      fontWeight: fontSizeController
                                          .obtainContrastFromBase(
                                              FontWeight.w600),
                                      color: Colors.white,
                                    ),
                                  ).tr(),
                                ],
                              ),
                      ),
                    IconButton(
                      alignment: Alignment.center,
                      color: Colors.white,
                      padding: EdgeInsets.all(0),
                      iconSize: 30,
                      icon: Icon(Icons.language),
                      onPressed: () {
                        nextScreenPopup(context, LanguagePopup());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: BlocListener<GpsBloc, GpsState>(
            listener: (context, state) {
              if (!state.isGpsPermissionGranted) {
                _showNoLocationDialog(context);
              }
            },
            child: Stack(
              children: [
                // Fondo para pantallas grandes
                if (!isMobile)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black12,
                  ),
                // Contenedor principal centrado
                Center(
                  child: Container(
                    width: containerWidth,
                    constraints: BoxConstraints(maxWidth: containerWidth),
                    child: Stack(
                      children: [
                        // Imagen de fondo
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(isMobile && isPortrait
                                    ? '${Config().media_url}/uploads/2024/09/login_app/back_home.jpg'
                                    : '${Config().media_url}/uploads/2024/09/login_app/back_home_2.png'),
                                fit: BoxFit.cover,
                                alignment: Alignment.center),
                          ),
                        ),
                        // Contenido centrado verticalmente en la mitad inferior
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: screenHeight *
                                    0.7, // Usa la mitad inferior de la pantalla
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Logo
                                    Container(
                                      height: 95,
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: spaceBetween),
                                    // Botón
                                    Center(
                                      child: widget.tag != null
                                          ? Container(
                                              height: 50,
                                              width: buttonWidth,
                                              child: TextButton(
                                                onPressed: () =>
                                                    handleGoogleSignIn(),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty
                                                          .resolveWith(
                                                              (states) => Colors
                                                                  .blueAccent),
                                                  shape: WidgetStateProperty
                                                      .resolveWith(
                                                    (states) =>
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                  ),
                                                ),
                                                child: googleSignInStarted
                                                    ? Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              FontAwesome
                                                                  .google,
                                                              color:
                                                                  Colors.white),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            'Sign In with Google',
                                                            style:
                                                                _textStyleMedium
                                                                    .copyWith(
                                                              fontWeight: fontSizeController
                                                                  .obtainContrastFromBase(
                                                                      FontWeight
                                                                          .w600),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ).tr(),
                                                        ],
                                                      ),
                                              ),
                                            )
                                          : Container(
                                              height: 50,
                                              width: buttonWidth,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: TextButton(
                                                style: ButtonStyle(
                                                  shape: WidgetStateProperty
                                                      .resolveWith(
                                                    (states) =>
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'get started',
                                                  style:
                                                      _textStyleLarge.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: fontSizeController
                                                        .obtainContrastFromBase(
                                                            FontWeight.w800),
                                                  ),
                                                ).tr(),
                                                onPressed: () => handleSkip(),
                                              ),
                                            ),
                                    ),
                                    SizedBox(
                                        height: screenHeight *
                                            0.1), // Espacio en la parte inferior
                                  ],
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
          ),
        );
      },
    );
  }
}
