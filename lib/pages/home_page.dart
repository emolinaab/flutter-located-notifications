import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:located_notifications/blocs/notifications_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.notificationsBloc,
    required this.title,
  }) : super(key: key);

  final String title;
  final NotificationsBloc notificationsBloc;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _title = '';
  String _body = '';

  @override
  void initState() {
    widget.notificationsBloc.notificationStream.listen(
      (RemoteMessage? message) {
        setState(() {
          _title = message?.notification?.title ?? '';
          _body = message?.notification?.body ?? '';
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Push Notification Title: $_title',
            ),
            Text(
              'Push Notification Body: $_body',
            ),
          ],
        ),
      ),
    );
  }
}
