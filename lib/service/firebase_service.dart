import "dart:developer" as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '/firebase_options.dart';



final FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();

Future initialize() async {
  var androidInitSet = const AndroidInitializationSettings("mipmap/ic_launcher");
  InitializationSettings initSet = InitializationSettings(android: androidInitSet);
  await notification.initialize(initSet);
}


Future<void> showNormalBox(String title, String body) async {
  AndroidNotificationDetails androidNotiDetails = const AndroidNotificationDetails(
    "Id of Notification",
    "This is a channel name",
    playSound: true,
    importance: Importance.max,
    priority: Priority.high
  );
  NotificationDetails notiDetails = NotificationDetails(android: androidNotiDetails);

  await notification.show(0, title, body, notiDetails);
}


Future<void> showFCMBox(RemoteMessage remoteMessage) async {
  AndroidNotificationDetails androidNotiDetails = const AndroidNotificationDetails(
    "Id of Notification",
    "This is a channel name",
    playSound: true,
    importance: Importance.max,
    priority: Priority.high
  );
  NotificationDetails notiDetails = NotificationDetails(android: androidNotiDetails);

  await notification.show(0, remoteMessage.data["body"], remoteMessage.data["title"], notiDetails);
}




class FirebaseService {
  
  static FirebaseApp firebaseApp = Firebase.app();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static String? token = "";
  static FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;
  


  static Future<void> initializeApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    NotificationSettings settings = await firebaseMessage.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if ((settings.authorizationStatus == AuthorizationStatus.authorized) || (settings.authorizationStatus == AuthorizationStatus.provisional)) {
      token = await firebaseMessage.getToken();
      developer.log("Firebase token: $token");
    }
    else {
      developer.log("Unable to notify message. Status: ${settings.authorizationStatus}");
    }
  }
}
