import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsBloc extends ChangeNotifier {
  bool _notificationsEnabled = false;
  SharedPreferences? _prefs;

  bool get notificationsEnabled => _notificationsEnabled;

  NotificationSettingsBloc() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _notificationsEnabled = _prefs?.getBool('notificationsEnabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    if (_prefs != null) {
      await _prefs!.setBool('notificationsEnabled', value);
      _notificationsEnabled = value;
      notifyListeners();
    }
  }

  Future<void> refreshSettings() async {
    _loadSettings();
  }
}