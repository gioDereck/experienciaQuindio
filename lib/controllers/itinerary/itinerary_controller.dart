import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_hour/config/config.dart';

class ItineraryController {
  // Token de autenticación
  static const String _authToken =
      '104|tERTv6JWIjAWFRuhf6iBc4rokKdmq35kStO7kpsib114af9d';

  final TextEditingController selectedPlace = TextEditingController();

  // Función para obtener compañeros de viaje
  Future<List<dynamic>> fetchTourCompanion() async {
    String url = Config().url; 
    String apiUrl ='${url}/api/get/travel-partner';

    try {
      Uri uri = Uri.parse(apiUrl);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      final data = jsonDecode(response.body);
      String status = data['status'];

      if (response.statusCode == 200 && status.toLowerCase() == "success") {
        final List<dynamic> companionData = data['message']['travelPartners'];
        return companionData;
      } else {
        throw Exception('Error: status no es success');
      }
    } catch (e) {
      print('Error al obtener compañeros de viaje: $e');
      throw Exception('Error al obtener compañeros de viaje: $e');
    }
  }

  // Función para obtener presupuestos de viaje
  Future<List<dynamic>> fetchTourBudget() async {
    String url = Config().url;
    String apiUrl = '${url}/api/get/trip-budget';

    try {
      Uri uri = Uri.parse(apiUrl);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      final data = jsonDecode(response.body);
      String status = data['status'];

      if (response.statusCode == 200 && status.toLowerCase() == "success") {
        final List<dynamic> budgetData = data['message']['travelBudgets'];
        return budgetData;
      } else {
        throw Exception('Error: status no es success');
      }
    } catch (e) {
      print('Error al obtener presupuestos de viaje: $e');
      throw Exception('Error al obtener presupuestos de viaje: $e');
    }
  }

  // Función para obtener preferencias de viaje
  Future<List<dynamic>> fetchTourPreference() async {
    String url = Config().url;
    String apiUrl = '${url}/api/get/travel-preferences';

    try {
      Uri uri = Uri.parse(apiUrl);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      final data = jsonDecode(response.body);
      String status = data['status'];

      if (response.statusCode == 200 && status.toLowerCase() == "success") {
        final List<dynamic> preferenceData = data['message']['travelBudgets'];
        return preferenceData;
      } else {
        throw Exception('Error: status no es success');
      }
    } catch (e) {
      print('Error al obtener preferencias de viaje: $e');
      throw Exception('Error al obtener preferencias de viaje: $e');
    }
  }

  // Funcion para guardar o actualizar el itinerario
}
