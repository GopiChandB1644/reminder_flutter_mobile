
import 'package:flutter/material.dart';
import 'package:reminderapp/notification/notification_service.dart';

import 'package:reminderapp/presentations/home_view.dart';
//import 'package:local_noti_tutorial/noti_service.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initNotifications:
  NotificationService().initNotification();

  // Initialize timezone package
  //tz.initializeTimeZones();

  // Get the local timezone from the device
  // final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  // tz.setLocalLocation(tz.getLocation(timeZoneName));

  // Initialize notifications
  // const AndroidInitializationSettings androidSettings =
  //     AndroidInitializationSettings('@mipmap/ic_launcher');

  // const InitializationSettings initializationSettings = InitializationSettings(
  //   android: androidSettings,
  // );

  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeView());
  }
}
