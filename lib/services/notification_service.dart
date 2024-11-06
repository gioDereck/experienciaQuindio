import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_hour/config/config.dart';

import '../pages/notifications.dart';
import '../utils/next_screen.dart';
import '../utils/notification_dialog.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static const String fcmSubscriptionTopicForAll = 'all';

  Future _handleNotificationPermissaion() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  // Future<void> subscribeWeb() async {
  //   try {
  //     // Solicitar permisos explícitamente para notificaciones en la web
  //     NotificationSettings settings = await _fcm.requestPermission(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );

  //     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //       debugPrint('Web: User granted permission');
  //       await _fcm.subscribeToTopic(fcmSubscriptionTopicForAll);
  //       debugPrint('Web: Subscribed to topic: $fcmSubscriptionTopicForAll');
  //     } else {
  //       debugPrint('Web: User declined or has not accepted permission');
  //     }
  //   } catch (e) {
  //     debugPrint('Web: Error subscribing to notifications: $e');
  //   }
  // }

  Future<String?> subscribeWeb() async {
    try {
      if (kIsWeb) {
        NotificationSettings settings = await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('Web: Permiso concedido');
          String? token = await _fcm.getToken(vapidKey: Config().privateKey);
          if (token != null) {
            // debugPrint('Web: Token generado: $token');
            return token; // Devuelve el token
          }
        } else {
          // debugPrint('Web: Permiso denegado o no aceptado');
        }
      } else {
        await _fcm.subscribeToTopic(fcmSubscriptionTopicForAll);
        // debugPrint('Móvil: Suscrito al tema: $fcmSubscriptionTopicForAll');
      }
    } catch (e) {
      debugPrint('Error al suscribirse a las notificaciones: $e');
    }
    return null;
  }

  Future<void> unsubscribeWeb() async {
    try {
      // Verificar si es web y manejar la desuscripción mediante el token
      if (kIsWeb) {
        String? token = await _fcm.getToken(vapidKey: Config().privateKey);
        if (token != null) {
          await _fcm.deleteToken();
          // debugPrint('Web: Token eliminado, desuscrito de notificaciones web');
        }
      } else {
        // Mantener la lógica original de desuscripción para móviles
        await _fcm.unsubscribeFromTopic(fcmSubscriptionTopicForAll);
        // debugPrint('Móvil: Desuscrito del tema: $fcmSubscriptionTopicForAll');
      }
    } catch (e) {
      debugPrint('Error al desuscribirse de las notificaciones: $e');
    }
  }

  Future initFirebasePushNotification(context) async {
    await _handleNotificationPermissaion();
    // String? token = await _fcm.getToken();
    // debugPrint('User FCM Token : $token}');

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();

    debugPrint('inittal message : $initialMessage');
    if (initialMessage != null) {
      nextScreen(context, NotificationsPage());
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("onMessage: $message");
      showinAppDialog(
          context, message.notification!.title, message.notification!.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      nextScreen(context, NotificationsPage());
    });
  }

  Future<bool?> checkingPermisson() async {
    bool? accepted;
    await _fcm
        .getNotificationSettings()
        .then((NotificationSettings settings) async {
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        accepted = true;
      } else {
        accepted = false;
      }
    });
    return accepted;
  }

  Future subscribe() async {
    await _fcm.subscribeToTopic(fcmSubscriptionTopicForAll);
  }

  Future unsubscribe() async {
    await _fcm.unsubscribeFromTopic(fcmSubscriptionTopicForAll);
  }
}
