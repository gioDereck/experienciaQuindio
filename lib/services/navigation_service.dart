import 'package:flutter/material.dart';
import 'package:travel_hour/pages/home.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();
  final _homeKey = GlobalKey<HomePageStatePublic>();

  GlobalKey<HomePageStatePublic> get homeKey => _homeKey;

  void navigateToIndex(int index) {
    _homeKey.currentState?.onTabTapped(index);
  }
}