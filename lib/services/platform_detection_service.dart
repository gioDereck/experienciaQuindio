import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:async';

class PlatformDetectionService extends ChangeNotifier {
  static final PlatformDetectionService _instance =
      PlatformDetectionService._internal();
  factory PlatformDetectionService() => _instance;

  bool _isMobileWeb = false;
  bool _isStandalone = false;
  late StreamSubscription<html.Event> _resizeSubscription;

  // Umbral de ancho para considerar vista móvil
  static const int MOBILE_WIDTH_THRESHOLD = 768;

  PlatformDetectionService._internal() {
    if (kIsWeb) {
      _updateMobileWebStatus();
      _updateStandaloneStatus();

      _resizeSubscription = html.window.onResize.listen((_) {
        _updateMobileWebStatus();
        notifyListeners();
      });
    }
  }

  void _updateMobileWebStatus() {
    if (kIsWeb) {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      final isUserAgentMobile = userAgent.contains('mobile') ||
          userAgent.contains('android') ||
          userAgent.contains('iphone') ||
          userAgent.contains('ipad') ||
          userAgent.contains('ipod');

      // Obtener el ancho actual de la ventana
      final currentWidth = html.window.innerWidth ?? 0;
      final isWidthMobile = currentWidth <= MOBILE_WIDTH_THRESHOLD;

      // Considerar móvil si el user agent es móvil O si el ancho es menor al umbral
      _isMobileWeb = isUserAgentMobile || isWidthMobile;
    }
  }

  void _updateStandaloneStatus() {
    if (kIsWeb) {
      _isStandalone =
          html.window.matchMedia('(display-mode: standalone)').matches;
    }
  }

  bool get isMobileWeb => _isMobileWeb;
  bool get isStandalone => _isStandalone;

  Map<String, dynamic> getDeviceInfo() {
    if (!kIsWeb) return {'platform': 'native_app'};

    final currentWidth = html.window.innerWidth ?? 0;
    final currentHeight = html.window.innerHeight ?? 0;

    return {
      'userAgent': html.window.navigator.userAgent,
      'platform': html.window.navigator.platform,
      'vendor': html.window.navigator.vendor,
      'language': html.window.navigator.language,
      'isMobile': _isMobileWeb,
      'isPwa': _isStandalone,
      'browser': getBrowserInfo(),
      'screenWidth': currentWidth,
      'screenHeight': currentHeight,
      'windowWidth': html.window.innerWidth,
      'windowHeight': html.window.innerHeight,
    };
  }

  String getBrowserInfo() {
    if (!kIsWeb) return 'native_app';

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains('firefox')) {
      return 'firefox';
    } else if (userAgent.contains('chrome')) {
      return 'chrome';
    } else if (userAgent.contains('safari')) {
      return 'safari';
    } else if (userAgent.contains('edge')) {
      return 'edge';
    } else if (userAgent.contains('opera')) {
      return 'opera';
    }
    return 'unknown';
  }

  Future<bool> get canInstallPwa async {
    if (!kIsWeb) return false;
    if (_isStandalone) return false;

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('chrome') || userAgent.contains('edge');
  }

  @override
  void dispose() {
    if (kIsWeb) {
      _resizeSubscription.cancel();
    }
    super.dispose();
  }
}
