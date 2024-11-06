import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/routes.dart';
import 'blocs/blog_bloc.dart';
import 'blocs/bookmark_bloc.dart';
import 'blocs/comments_bloc.dart';
import 'blocs/featured_bloc.dart';
import 'blocs/notification_bloc.dart';
import 'blocs/other_places_bloc.dart';
import 'blocs/popular_places_bloc.dart';
import 'blocs/recent_places_bloc.dart';
import 'blocs/recommanded_places_bloc.dart';
import 'blocs/search_bloc.dart';
import 'blocs/sign_in_bloc.dart';
import 'blocs/sp_state_one.dart';
import 'blocs/sp_state_two.dart';
import 'blocs/state_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FontSizeController fontSizeController = Get.put(FontSizeController());

  @override
  Widget build(BuildContext context) {
    final _router = goRouter();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BlogBloc>(
          create: (context) => BlogBloc(),
        ),
        ChangeNotifierProvider<SignInBloc>(
          create: (context) => SignInBloc(),
        ),
        ChangeNotifierProvider<CommentsBloc>(
          create: (context) => CommentsBloc(),
        ),
        ChangeNotifierProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(),
        ),
        ChangeNotifierProvider<PopularPlacesBloc>(
          create: (context) => PopularPlacesBloc(),
        ),
        ChangeNotifierProvider<RecentPlacesBloc>(
          create: (context) => RecentPlacesBloc(),
        ),
        ChangeNotifierProvider<RecommandedPlacesBloc>(
          create: (context) => RecommandedPlacesBloc(),
        ),
        ChangeNotifierProvider<FeaturedBloc>(
          create: (context) => FeaturedBloc(),
        ),
        ChangeNotifierProvider<SearchBloc>(create: (context) => SearchBloc()),
        ChangeNotifierProvider<NotificationBloc>(
            create: (context) => NotificationBloc()),
        ChangeNotifierProvider<StateBloc>(create: (context) => StateBloc()),
        ChangeNotifierProvider<SpecialStateOneBloc>(
            create: (context) => SpecialStateOneBloc()),
        ChangeNotifierProvider<SpecialStateTwoBloc>(
            create: (context) => SpecialStateTwoBloc()),
        ChangeNotifierProvider<OtherPlacesBloc>(
            create: (context) => OtherPlacesBloc()),
        // ChangeNotifierProvider<AdsBloc>(create: (context) => AdsBloc()),
      ],
      child: Obx(() {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          locale: context.locale,
          theme: ThemeData(
            textTheme: TextTheme(
                displayLarge: TextStyle(
                  fontSize: fontSizeController.fontSizeHyperLarge.value,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w900),
                ),
                titleLarge: TextStyle(
                  fontSize: fontSizeController.fontSizeExtraLarge.value,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w700),
                ),
                bodyLarge: TextStyle(
                  fontSize: fontSizeController.fontSizeLarge.value,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w600),
                ),
                bodyMedium: TextStyle(
                  fontSize: fontSizeController.fontSizeMedium.value,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w500),
                ),
                bodySmall: TextStyle(
                  fontSize: fontSizeController.fontSizeTiny.value,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w400),
                )),
            useMaterial3: false,
            primarySwatch: Colors.blue,
            primaryColor: Config.appThemeColor,
            iconTheme: IconThemeData(color: Colors.grey[900]),
            fontFamily: 'Manrope',
            scaffoldBackgroundColor: Colors.grey[100],
            appBarTheme: AppBarTheme(
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.grey[800],
              ),
              titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w600),
                  fontFamily: 'Manrope',
                  color: Colors.grey[900]),
            ),
          ),
        );
      }),
    );
  }
}
