import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/models/place.dart';

class RecentPlacesBloc extends ChangeNotifier{
  List<Place> _data = [];
  List<Place> get data => _data;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future getData() async {
    QuerySnapshot rawData;
      rawData = await firestore
          .collection('places')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      
      List<DocumentSnapshot> _snap = [];
      _snap.addAll(rawData.docs);
      _data = _snap.map((e) => Place.fromFirestore(e))
        .where((place) {
          return place.isDepartment == null;
        })
        .toList();
      notifyListeners();
    
    
  }
  onRefresh(mounted) {
    _data.clear();
    getData();
    notifyListeners();
  }
}