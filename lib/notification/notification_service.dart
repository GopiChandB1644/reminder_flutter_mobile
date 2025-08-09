import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final notificationsplugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  //Initialize
  Future<void> initNotification() async {
    if (_isInitialized) return;

    //init timeZone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // android init setting
    const initSettingAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    //init setting
    const initSetting = InitializationSettings(android: initSettingAndroid);

    //finally initialize the plugin
    await notificationsplugin.initialize(initSetting);
    _isInitialized = true;
  }

  //notification details setup
  NotificationDetails notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel_id',
        'Reminder Notifications',
        channelDescription: 'Daily reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  //show notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationsplugin.show(id, title, body, notificationDetails());
  }

  //scheduleNotification:

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    //Get the current date/time in devices local timezone
    final now = tz.TZDateTime.now(tz.local);

    //create a date/time for today at the specific hour/min
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    //scheduleNotification
    await notificationsplugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(),

      //AndroidSpecific:
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      //make notification repeat daily at the same time
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await notificationsplugin.cancelAll();
  }

  tz.TZDateTime _getNextInstanceOfDayAndTime(
    String dayName,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);

    // Map day names to weekday numbers (1 = Monday, 7 = Sunday)
    final dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    final targetWeekday = dayMap[dayName] ?? 1;

    // Create a datetime for today at the specified time
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now) || scheduledDate.weekday != targetWeekday) {
      int daysToAdd = (targetWeekday - now.weekday + 7) % 7;
      if (daysToAdd == 0 && scheduledDate.isBefore(now)) {
        daysToAdd = 7;
      }
      scheduledDate = scheduledDate.add(Duration(days: daysToAdd));
    }
    return scheduledDate;
  }

  // Helper function for debugging
  // String _getWeekdayName(int weekday) {
  //   const names = {
  //     1: 'Monday',
  //     2: 'Tuesday',
  //     3: 'Wednesday',
  //     4: 'Thursday',
  //     5: 'Friday',
  //     6: 'Saturday',
  //     7: 'Sunday',
  //   };
  //   return names[weekday] ?? 'Unknown';
  // }

  Future<void> scheduleNotificationForDay({
    required int id,
    required String title,
    required String body,
    required String dayName,
    required int hour,
    required int minute,
  }) async {
    final scheduledDate = _getNextInstanceOfDayAndTime(dayName, hour, minute);

    print('Scheduling notification for $dayName at $hour:$minute');
    print('Next occurrence: $scheduledDate');

    await notificationsplugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // canceling specific notifications
  Future<void> cancelNotification(int id) async {
    await notificationsplugin.cancel(id);
  }
}
