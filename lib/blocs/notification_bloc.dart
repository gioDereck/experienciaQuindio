import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../services/sp_service.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;

  String? token;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool? _hasData;
  bool? get hasData => _hasData;

  List<DocumentSnapshot> _snap = [];

  List<NotificationModel> _data = [];
  List<NotificationModel> get data => _data;

  bool _subscribed = false;
  bool get subscribed => _subscribed;

  Future<Null> getData(mounted, context) async {
    _hasData = true;
    QuerySnapshot rawData;
    if (_lastVisible == null)
      rawData = await firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    else
      rawData = await firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible!['timestamp']])
          .limit(10)
          .get();

    if (rawData.docs.length > 0) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        _isLoading = false;
        _snap.addAll(rawData.docs);
        _data = _snap
            .map((e) => NotificationModel.fromFirestore(e, context))
            .toList();
      }
    } else {
      if (_lastVisible == null) {
        _isLoading = false;
        _hasData = false;
      } else {
        _isLoading = false;
        _hasData = true;
      }
    }

    notifyListeners();
    return null;
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  onRefresh(mounted, context) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted, context);
    notifyListeners();
  }

  onReload(mounted, context) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted, context);
    notifyListeners();
  }

  Future checkPermission() async {
    await NotificationService()
        .checkingPermisson()
        .then((bool? accepted) async {
      if (accepted != null && accepted) {
        checkSubscription();
      } else {
        await SPService().setNotificationSubscription(false);
        _subscribed = false;
        notifyListeners();
      }
    });
  }

  Future checkSubscription() async {
    await SPService().getNotificationSubscription().then((bool value) async {
      if (value) {
        await NotificationService().subscribe();
        _subscribed = true;
      } else {
        await NotificationService().unsubscribe();
        _subscribed = false;
      }
    });
    notifyListeners();
  }

  Future saveToken(String token) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await sp.setString('push_notification_token', token);
    await sp.setString('notification_token_timestamp', timestamp);
    this.token = token;

    //print("Timestamp a guardar: $timestamp");
    firestore.collection('push_notification_token').doc(timestamp).set({
      'token': token
    });

    notifyListeners();
  }

  Future<void> removeToken() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? timestamp = sp.getString('notification_token_timestamp');
    this.token = null;

    //print("Timestamp a eliminar: $timestamp");
    if (timestamp != null) {
      try {
        await firestore
            .collection('push_notification_token')
            .doc(timestamp)
            .delete();
        await sp.remove('push_notification_token');
        await sp.remove('notification_token_timestamp');
      } catch (e) {
        print("Error al eliminar el token de Firestore: $e");
      }
    }

    notifyListeners();
  }

  handleSubscription(context, bool newValue, SharedPreferences? sp) async {
    _subscribed = newValue;
    notifyListeners();    

    if (newValue) {
      // Proceso de suscripción
      String? token = await NotificationService().subscribeWeb();
      sp!.setBool('notificationEnabled', true);
      
      if (token != null) {
        await saveToken(token); // Guarda el token
      }
      await SPService().setNotificationSubscription(newValue);
      Fluttertoast.showToast(
          msg: kIsWeb
              ? easy.tr('notifications_on_web')
              : easy.tr('notifications_turned_on'));
      _subscribed = true;
    } else {
      sp!.setBool('notificationEnabled', false);

      // Proceso de desuscripción
      await NotificationService().unsubscribeWeb();
      await removeToken(); // Llama a removeToken para eliminar el token
      await SPService().setNotificationSubscription(newValue);
      Fluttertoast.showToast(
          msg: kIsWeb
              ? easy.tr('notifications_off_web')
              : easy.tr('notifications_turned_off'));
      _subscribed = false;
    }

    notifyListeners();
  }
}
