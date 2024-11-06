import 'package:travel_hour/utils/toast.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

class MapService {
  MapService._();

  /*
  static void initializeGoogleMaps(js) {
    if (kIsWeb) {
      js.context.callMethod('initializeGoogleMaps', [Config().mapAPIKey]);
    }
  }
  */

  static Future<void> openMap(
      double latitude, double longitude, String placeId, context) async {
    final String googleUrlforIos =
        'comgooglemapsurl://www.google.com/maps/search/?api=1&query=$latitude$longitude&query_place_id=$placeId';
    final String googleUrlforAndroid =
        'https://www.google.com/maps/search/?api=1&query=$latitude$longitude&query_place_id=$placeId';
    final String appleUrl = 'https://maps.apple.com/?q=$latitude,$longitude';
    final String webUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude'; // URL para web
    if (UniversalPlatform.isWeb) {
      // Si estamos en la web, abrir el enlace en el navegador
      final Uri uri = Uri.parse(webUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        openToast1(context, 'No se puede abrir Google Maps en el navegador.');
      }
    } else if (UniversalPlatform.isAndroid) {
      final Uri uri = Uri.parse(googleUrlforAndroid);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        openToast1(context, 'Google Maps App is required for this action');
      }
    } else if (UniversalPlatform.isIOS) {
      final Uri param = Uri.parse("comgooglemaps://");
      final Uri uri = Uri.parse(googleUrlforIos);
      final Uri uri1 = Uri.parse(appleUrl);
      if (await canLaunchUrl(param)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri1);
      }
    }
  }
}
