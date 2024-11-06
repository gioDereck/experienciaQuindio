import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:travel_hour/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TripExploreController extends GetxController {
  final ScrollController scrollController = ScrollController();
  List<TripModel> tripList = [];
  List<UpcomingTripModel> upcomingTripList = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoading = false;
  bool isScreenLoading = false;

  @override
  void onInit() {
    super.onInit();
    fetchSavedTrip();
  }

  // fetch ticket list
  Future<void> fetchSavedTrip() async {
    String authToken = '104|tERTv6JWIjAWFRuhf6iBc4rokKdmq35kStO7kpsib114af9d';
    isScreenLoading = true;
    update();

    try {
      String url = Config().url;
      String apiUrl = '${url}/api/explore-list?page=1';
      Uri uri = WebUri(apiUrl);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      final data = jsonDecode(response.body);
      String status = data['status'];

      if (response.statusCode == 200) {
        if (status.toLowerCase() == "success") {
          final List<dynamic> tripData = data['message']['tripExplore']['data'];
          // En lugar de addAll, asignamos directamente
          tripList = tripData.map((json) => TripModel.fromJson(json)).toList();
          currentPage = data['message']['tripExplore']['current_page'];
          lastPage = data['message']['tripExplore']['last_page'];
        } else {
          if (kDebugMode) {
            print('Failed to load saved trips ---------->');
          }
        }
      } else {
        throw Exception('Failed to load saved trips ---------->');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load saved trips ----------> $e');
      }
    } finally {
      isScreenLoading = false;
      update();
    }
  }
  
  Future<void> refreshAllData() async {
    tripList.clear();
    await fetchSavedTrip();
  }

  Future<void> loadMoreData() async {
    if (currentPage < lastPage) {
      currentPage++;
      await fetchSavedTrip();
    }
  }
}

class TripModel {
  final int id;
  final int userId;
  final TripRequest tripRequest;
  final String aiResponse;
  final int status;
  final String createdAt;
  final String updatedAt;

  TripModel({
    required this.id,
    required this.userId,
    required this.tripRequest,
    required this.aiResponse,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      userId: json['user_id'],
      tripRequest: TripRequest.fromJson(json['trip_request']),
      aiResponse: json['ai_response'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'trip_request': tripRequest.toMap(),
      'ai_response': aiResponse,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UpcomingTripModel {
  final int id;
  final int userId;
  final TripRequest tripRequest;
  final String aiResponse;
  final int status;
  final String reminderDate;
  final String reminderMsg;
  final String createdAt;
  final String updatedAt;

  UpcomingTripModel({
    required this.id,
    required this.userId,
    required this.tripRequest,
    required this.aiResponse,
    required this.status,
    required this.reminderDate,
    required this.reminderMsg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UpcomingTripModel.fromJson(Map<String, dynamic> json) {
    return UpcomingTripModel(
      id: json['id'],
      userId: json['user_id'],
      tripRequest: TripRequest.fromJson(json['trip_request']),
      aiResponse: json['ai_response'],
      status: json['status'],
      reminderDate: json['reminder_date'],
      reminderMsg: json['reminder_msg'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class TripRequest {
  final String language;
  final String place;
  final String startDate;
  final String endDate;
  final String travelPartner;
  final String tripBudget;
  final String travelPreference;

  TripRequest({
    required this.language,
    required this.place,
    required this.startDate,
    required this.endDate,
    required this.travelPartner,
    required this.tripBudget,
    required this.travelPreference,
  });

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    return TripRequest(
      language: json['language'],
      place: json['place'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      travelPartner: json['travelPartner'],
      tripBudget: json['tripBudget'],
      travelPreference: json['travelPreference'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'place': place,
      'start_date': startDate,
      'end_date': endDate,
      'travelPartner': travelPartner,
      'tripBudget': tripBudget,
      'travelPreference': travelPreference,
    };
  }
}
