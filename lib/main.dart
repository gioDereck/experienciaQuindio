import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_hour/blocs/gps/gps_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));

  // Configura la estrategia de URL para evitar agregar # a las rutas
  usePathUrlStrategy();

  runApp(EasyLocalization(
      supportedLocales: [Locale('en'), Locale('es'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: Locale('es'),
      startLocale: Locale('es'),
      useOnlyLangCode: true,
      child: MultiBlocProvider(
        providers: [BlocProvider(create: (context) => GpsBloc())],
        child: const MyApp(),
      )));
}
