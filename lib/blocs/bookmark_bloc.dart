import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/models/place.dart';

class BookmarkBloc extends ChangeNotifier {
  List<Place> _bookmarkedPlaces = [];
  List<Place> get bookmarkedPlaces => _bookmarkedPlaces;

  Future<List> getPlaceData() async {
    String collectionName = 'places';
    String type = 'bookmarked places';
    List<Place> data = [];
    List<DocumentSnapshot> _snap = [];

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? _uid = sp.getString('uid');

      if (_uid == null) {
        // print('No user ID found');
        return data;
      }

      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(_uid);
      DocumentSnapshot snap = await ref.get();

      if (!snap.exists) {
        // print('User document does not exist');
        await ref.set({
          'bookmarked places': [],
          'bookmarked blogs': [],
          'loved places': [],
          'loved blogs': []
        });
        return data;
      }

      // Convertir snap.data() a Map<String, dynamic>
      final userData = snap.data() as Map<String, dynamic>;

      if (!userData.containsKey(type)) {
        print('Field $type does not exist in user document');
        await ref.update({type: []});
        return data;
      }

      List d = userData[type] as List;

      if (d.isNotEmpty) {
        QuerySnapshot rawData = await FirebaseFirestore.instance
            .collection(collectionName)
            .where('timestamp', whereIn: d)
            .get();
        _snap.addAll(rawData.docs);
        data = _snap.map((e) => Place.fromFirestore(e)).toList();
        _bookmarkedPlaces = data;
      }

      return data;
    } catch (e) {
      print('Error in getPlaceData: $e');
      return data;
    }
  }

  Future<List> getBlogData() async {
    String collectionName = 'blogs';
    String type = 'bookmarked blogs';
    List<Blog> data = [];
    List<DocumentSnapshot> _snap = [];

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? _uid = sp.getString('uid');

      if (_uid == null) {
        print('No user ID found');
        return data;
      }

      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(_uid);
      DocumentSnapshot snap = await ref.get();

      if (!snap.exists) {
        print('User document does not exist');
        await ref.set({
          'bookmarked places': [],
          'bookmarked blogs': [],
          'loved places': [],
          'loved blogs': []
        });
        return data;
      }

      // Convertir snap.data() a Map<String, dynamic>
      final userData = snap.data() as Map<String, dynamic>;

      if (!userData.containsKey(type)) {
        print('Field $type does not exist in user document');
        await ref.update({type: []});
        return data;
      }

      List d = userData[type] as List;

      if (d.isNotEmpty) {
        QuerySnapshot rawData = await FirebaseFirestore.instance
            .collection(collectionName)
            .where('timestamp', whereIn: d)
            .get();
        _snap.addAll(rawData.docs);
        data = _snap.map((e) => Blog.fromFirestore(e)).toList();
      }

      return data;
    } catch (e) {
      print('Error in getBlogData: $e');
      return data;
    }
  }

  Future onBookmarkIconClick(String collectionName, String? timestamp) async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      String? _uid = sp.getString('uid');

      if (_uid == null) return;

      String _type =
          collectionName == 'places' ? 'bookmarked places' : 'bookmarked blogs';

      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(_uid);
      DocumentSnapshot snap = await ref.get();

      if (!snap.exists) {
        await ref.set({_type: []});
        snap = await ref.get();
      }

      // Convertir snap.data() a Map<String, dynamic>
      final userData = snap.data() as Map<String, dynamic>;
      List d = userData[_type] as List;

      if (d.contains(timestamp)) {
        List a = [timestamp];
        await ref.update({_type: FieldValue.arrayRemove(a)});
      } else {
        await ref.update({
          _type: FieldValue.arrayUnion([timestamp])
        });
      }

      await refreshData();
    } catch (e) {
      print('Error in onBookmarkIconClick: $e');
    }
  }

  Future onLoveIconClick(String collectionName, String? timestamp) async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      String? _uid = sp.getString('uid');

      if (_uid == null) return;

      String _type =
          collectionName == 'places' ? 'loved places' : 'loved blogs';

      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(_uid);
      final DocumentReference ref1 =
          FirebaseFirestore.instance.collection(collectionName).doc(timestamp);

      DocumentSnapshot snap = await ref.get();
      DocumentSnapshot snap1 = await ref1.get();

      if (!snap.exists) {
        await ref.set({_type: []});
        snap = await ref.get();
      }

      // Convertir snap.data() a Map<String, dynamic>
      final userData = snap.data() as Map<String, dynamic>;
      List d = userData[_type] as List;

      // Convertir snap1.data() a Map<String, dynamic>
      final itemData = snap1.data() as Map<String, dynamic>;
      int _loves = itemData['loves'] ?? 0;

      if (d.contains(timestamp)) {
        List a = [timestamp];
        await ref.update({_type: FieldValue.arrayRemove(a)});
        await ref1.update({'loves': _loves - 1});
      } else {
        await ref.update({
          _type: FieldValue.arrayUnion([timestamp])
        });
        await ref1.update({'loves': _loves + 1});
      }

      await refreshData();
    } catch (e) {
      print('Error in onLoveIconClick: $e');
    }
  }

  Future<void> refreshData() async {
    try {
      await getPlaceData();
      notifyListeners();
    } catch (e) {
      print('Error in refreshData: $e');
    }
  }
}
