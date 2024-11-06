import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  // Función para guardar la ubicación
  Future<void> saveLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);

    //print('Location Service: ${latitude}, ${longitude}');
  }

  // Función para obtener la ubicación guardada
  Future<Map<String, double>?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('latitude');
    double? longitude = prefs.getDouble('longitude');

    if (latitude != null && longitude != null) {
      return {
        'latitude': latitude,
        'longitude': longitude
      }; // Devuelve un mapa con lat y lng
    }
    return null; // No hay ubicación guardada
  }
}
