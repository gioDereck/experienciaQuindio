import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/blogs.dart';
import 'package:travel_hour/pages/bookmark.dart';
import 'package:travel_hour/pages/coffee_routes_list.dart';
import 'package:travel_hour/pages/emergency_numbers.dart';
import 'package:travel_hour/pages/explore.dart';
import 'package:travel_hour/pages/game_menu.dart';
import 'package:travel_hour/pages/home.dart';
import 'package:travel_hour/pages/ia_options.dart';
import 'package:travel_hour/pages/intro.dart';
import 'package:travel_hour/pages/more_places.dart';
import 'package:travel_hour/pages/notifications.dart';
import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/pages/profile.dart';
import 'package:travel_hour/pages/qr_code.dart';
import 'package:travel_hour/pages/qr_list.dart';
import 'package:travel_hour/pages/quindio_map.dart';
import 'package:travel_hour/pages/sign_in.dart';
import 'package:travel_hour/pages/splash.dart';
import 'package:travel_hour/pages/states.dart';

final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver firebaseObserver =
    FirebaseAnalyticsObserver(analytics: firebaseAnalytics);

GoRouter goRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          return SplashPage();
        },
      ),
      GoRoute(
        path: '/sig-in',
        name: 'sig-in',
        builder: (context, state) {
          return SignInPage();
        },
      ),
      GoRoute(
        path: '/intro',
        name: 'intro',
        builder: (context, state) {
          return IntroPage();
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          GoRoute(
            path: '/explore',
            name: 'explore', // Agrega el nombre de la ruta
            builder: (context, state) => Explore(),
          ),
          GoRoute(
            path: '/states',
            name: 'states', // Agrega el nombre de la ruta
            builder: (context, state) => StatesPage(),
          ),
          GoRoute(
            path: '/blogs',
            name: 'blogs', // Agrega el nombre de la ruta
            builder: (context, state) => BlogPage(),
          ),
          GoRoute(
            path: '/bookmarks',
            name: 'bookmarks', // Agrega el nombre de la ruta
            builder: (context, state) => BookmarkPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile', // Agrega el nombre de la ruta
            builder: (context, state) => ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/emergency_numbers',
        name: 'emergency_numbers',
        builder: (context, state) => EmergencyNumbersPage(),
      ),
      GoRoute(
        path: '/qr_scanner',
        name: 'qr_scanner',
        builder: (context, state) => QrCodePage(),
      ),
      GoRoute(
        path: '/ia_options',
        name: 'ia_options',
        builder: (context, state) => IaOptionsPage(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => NotificationsPage(),
      ),
      GoRoute(
        path: '/ar_qr',
        name: 'ar_qr',
        builder: (context, state) => ImmersionQRPage(),
      ),
      GoRoute(
        path: '/interactive_map',
        name: 'interactive_map',
        builder: (context, state) => QuindioMap(),
      ),
      GoRoute(
        path: '/coffee_routes',
        name: 'coffee_routes',
        builder: (context, state) => CoffeeRoutesList(),
      ),
      GoRoute(
        path: '/games',
        name: 'games',
        builder: (context, state) => GamesMenuScreen(),
      ),
      GoRoute(
        path: '/coffee-routes',
        name: 'coffee-routes',
        builder: (context, state) {
          return CoffeeRoutesList();
        },
      ),
      GoRoute(
        path: '/place-details',
        name: 'place-details',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          return PlaceDetails(
            data: args?['data'] as Place?,
            tag: args?['tag'] as String? ?? '',
            itComeFromHome: args?['itComeFromHome'] ?? false,
            previousRoute: args?['previous_route'],
          );
        },
      ),
      GoRoute(
          path: '/places',
          name: 'places',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;

            return MorePlacesPage(
              title: args?['title'] as String? ?? 'recommended',
              color: args?['color'] ?? Colors.green[300],
              previousRoute: args?['previous_route'] ?? 'home',
            );
          })
    ],
    // Integrar Firebase Analytics con la navegación de la App
    observers: [firebaseObserver],
  );
}
