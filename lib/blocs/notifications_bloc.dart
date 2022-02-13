import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../firebase_options.dart';
import 'location_bloc.dart';

class NotificationsBloc {
  NotificationsBloc();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static final LocationBloc _locationBloc = LocationBloc();

  static final StreamController<RemoteMessage?> _notificationController =
      StreamController<RemoteMessage?>.broadcast();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Stream<RemoteMessage?> notificationStream =
      _notificationController.stream;

  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      const IOSInitializationSettings();

  late FirebaseMessaging _messaging;

  static Future<bool> _locateNotification(
    Position notificationPosition,
    double radius,
  ) async {
    return await _locationBloc.isPositionNear(
      notificationPosition,
      radius,
    );
  }

  static Future<void> _processMessage(RemoteMessage message) async {
    var notificationData = message.data;
    var isLocated = await _locateNotification(
      Position.fromMap(
        {
          'longitude': double.parse(notificationData['lng']),
          'latitude': double.parse(notificationData['lat']),
        },
      ),
      double.parse(notificationData['radius']),
    );

    if (isLocated) {
      _showNotification(
        notificationData['body'],
        notificationData['title'],
      );

      _notificationController.add(message);
    }
  }

  static Future<void> _showNotification(String body, String title) async {
    flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
        ),
      ),
    );
  }

  init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _messaging = FirebaseMessaging.instance;

    await _requestPermission();
    FirebaseMessaging.instance.subscribeToTopic('locatednotification');

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _notificationController.add(initialMessage);
    }

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

  void _onSelectNotification(String? payload) {}

  Future<void> _requestPermission() async {
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
}
