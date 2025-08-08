import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationsplugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  //Initialize
  Future<void> initNotification() async {
    if (_isInitialized) return;

    //prepare android init setting
    const initSettingAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    //init setting
    const initSetting = InitializationSettings(android: initSettingAndroid);

    //finally initialize the plugin
    await notificationsplugin.initialize(initSetting);
  }

  //notification details setup
  NotificationDetails notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  //show notification
  Future<void> showNotification({
    int id=0,
    String? title,
    String? body,
  })async{
    return notificationsplugin.show(id, title, body, NotificationDetails());
  }
}
