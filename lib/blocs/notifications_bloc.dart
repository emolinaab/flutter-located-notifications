import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

class NotificationsBloc {
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static final StreamController<RemoteMessage?> _notificationController =
      StreamController<RemoteMessage?>.broadcast();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Stream<RemoteMessage?> get notificationStream =>
      _notificationController.stream;

  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      const IOSInitializationSettings();

  late FirebaseMessaging _messaging;

  static Future<void> _processMessage(RemoteMessage message) async {
    var notificationData = message.data;

    flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        notificationData['title'],
        notificationData['body'],
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
          ),
        ));

    _notificationController.add(
      message,
    );
  }

  init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _messaging = FirebaseMessaging.instance;

    await _requestPermission();
    FirebaseMessaging.instance.subscribeToTopic('locatednotification');
    FirebaseMessaging.onMessage.listen(_processMessage);

    FirebaseMessaging.onBackgroundMessage(_processMessage);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      ),
      onSelectNotification: _onSelectNotification,
    );
  }

  _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void _onSelectNotification(String? payload) {}
}
