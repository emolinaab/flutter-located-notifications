import 'package:flutter/material.dart';
import 'blocs/notifications_bloc.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationsBloc _notificationsBloc = NotificationsBloc();

  @override
  void initState() {
    _notificationsBloc.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Located Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(
          notificationsBloc: _notificationsBloc,
          title: 'Located Notifications'),
    );
  }
}
