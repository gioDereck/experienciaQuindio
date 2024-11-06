import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HashDateservice {
  static const String _dateKey = 'storedDate';
  static const String _hashKey = 'dateHash';

  // Almacenar la fecha, hora actual y el hash
  Future<void> storeCurrentDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Verificar si el hash ya está almacenado
    if (prefs.getString(_hashKey) == null) {
      final now = DateTime.now();
      final String dateString =
          now.toIso8601String(); // Convertir a cadena ISO 8601

      // Generar un hash de la fecha
      final String hash = _generateHash(dateString);

      // Almacenar en SharedPreferences
      await prefs.setString(_dateKey, dateString);
      await prefs.setString(_hashKey, hash);
    } else {
      // Solo actualizar la fecha sin cambiar el hash
      final now = DateTime.now();
      final String dateString =
          now.toIso8601String(); // Convertir a cadena ISO 8601
      await prefs.setString(_dateKey, dateString); // Actualizar solo la fecha
    }
  }

  // Generar un hash utilizando SHA-256
  String _generateHash(String input) {
    final bytes = utf8.encode(input); // Convertir a bytes
    final digest = sha256.convert(bytes); // Generar el hash
    return digest.toString(); // Devolver el hash como cadena
  }

  // Obtener la fecha almacenada y calcular la diferencia en horas
  Future<bool> isDifferenceGreaterThan(double hours) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedDateString = prefs.getString(_dateKey);

    if (storedDateString != null) {
      DateTime storedDate = DateTime.parse(storedDateString);
      DateTime currentDate = DateTime.now();

      double differenceInHours =
          currentDate.difference(storedDate).inHours.toDouble();
      return differenceInHours >
          hours; // Retorna true si la diferencia es mayor que las horas especificadas
    }

    return false; // Si no hay fecha almacenada, retorna false
  }

  // Método para verificar si la fecha ya está almacenada
  Future<bool> isDateStored() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedDateString = prefs.getString(_dateKey);
    return storedDateString != null; // Retorna true si hay una fecha almacenada
  }

  // Método para obtener el hash almacenado
  Future<String?> getStoredHash() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hashKey);
  }
}
