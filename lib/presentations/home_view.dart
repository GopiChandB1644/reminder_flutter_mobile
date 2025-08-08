// home_view.dart
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:reminderapp/model/reminder_model.dart';
import 'package:reminderapp/notification/notification_service.dart';
//import 'package:reminder_app/main.dart'; // access flutterLocalNotificationsPlugin and scheduling functions
//import 'package:reminder_app/model/reminder_model.dart';
//import 'package:reminder_app/storage/reminder_storage.dart';
import 'package:reminderapp/storage/reminder_storage.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:permission_handler/permission_handler.dart'; // added
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? selectedDay;
  TimeOfDay? selectedTime;
  String? _selectedTimeText = "Select Time";
  String? selectedActivity;
  final _formkey = GlobalKey<FormState>();

  //List of week days
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // Activity List
  List<String> activities = [
    "Wake up",
    "Go to gym",
    "Breakfast",
    "Meetings",
    "Lunch",
    "Quick nap",
    "Go to library",
    "Dinner",
    "Go to sleep",
  ];

  List<ReminderModel> reminders = [];

  @override
  void initState() {
    super.initState();

    // Request notification permission on app start
    //requestNotificationPermission();

    ReminderStorage.getReminders().then((loadedReminders) {
      setState(() {
        reminders = loadedReminders;
      });
    });
  }

  // Request notification permission (Android 13+)
  // Future<void> requestNotificationPermission() async {
  //   if (await Permission.notification.isDenied) {
  //     await Permission.notification.request();
  //   }
  // }

  // Time Formatting
  String get formattedTime {
    if (selectedTime == null) return "Pick Time";
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    return DateFormat.jm().format(dt); // e.g., 4:30 PM
  }

  Future<void> _pickedTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _selectedTimeText = formattedTime;
      });
    }
  }

  // *** Helper functions for scheduling notifications ***

  // int _weekdayToInt(String day) {
  //   switch (day) {
  //     case 'Monday':
  //       return DateTime.monday;
  //     case 'Tuesday':
  //       return DateTime.tuesday;
  //     case 'Wednesday':
  //       return DateTime.wednesday;
  //     case 'Thursday':
  //       return DateTime.thursday;
  //     case 'Friday':
  //       return DateTime.friday;
  //     case 'Saturday':
  //       return DateTime.saturday;
  //     default:
  //       return DateTime.monday;
  //   }
  // }

  // tz.TZDateTime _nextInstanceOfDayTime(String day, TimeOfDay time) {
  //   final now = tz.TZDateTime.now(tz.local);
  //   int weekday = _weekdayToInt(day);

  //   tz.TZDateTime scheduledDate = tz.TZDateTime(
  //     tz.local,
  //     now.year,
  //     now.month,
  //     now.day,
  //     time.hour,
  //     time.minute,
  //   );

  //   int daysToAdd = (weekday - scheduledDate.weekday) % 7;
  //   if (daysToAdd == 0 && scheduledDate.isBefore(now)) {
  //     daysToAdd = 7;
  //   }

  //   scheduledDate = scheduledDate.add(Duration(days: daysToAdd));
  //   return scheduledDate;
  //}
  //
  // Future<void> scheduleNotification(
  //   String title,
  //   String body,
  //   tz.TZDateTime scheduledDate,
  // ) async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //         'reminder_channel_id',
  //         'Reminders',
  //         channelDescription: 'Channel for reminder notifications',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       );
  //
  //   const NotificationDetails platformDetails = NotificationDetails(
  //     android: androidDetails,
  //   );
  //
  //   // Use millisecondsSinceEpoch ~/ 1000 as unique notification ID
  //   int notificationId = scheduledDate.millisecondsSinceEpoch ~/ 1000;
  //
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     scheduledDate.hashCode,
  //     title,
  //     body,
  //     scheduledDate,
  //     platformDetails,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reminder App"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DropdownButtonFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "please select one option";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                hint: Text("Select Day"),
                value: selectedDay,
                icon: Icon(Icons.arrow_drop_down),
                style: TextStyle(color: Colors.black, fontSize: 18),
                items: days.map<DropdownMenuItem<String>>((String day) {
                  return DropdownMenuItem<String>(value: day, child: Text(day));
                }).toList(),
                onChanged: (String? newvalue) {
                  setState(() {
                    selectedDay = newvalue;
                  });
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField(
                validator: (value) {
                  if (value == null || value.isEmpty || selectedTime == null) {
                    return "please select one option";
                  }
                  return null;
                },
                value: _selectedTimeText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                hint: Text("Selected Time"),
                items: [
                  DropdownMenuItem(
                    value: _selectedTimeText,
                    child: Text(
                      _selectedTimeText ?? "Selected Time",
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ],
                onChanged: (val) {
                  _pickedTime(context);
                },
              ),
              SizedBox(height: 25),
              DropdownButtonFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "please select one option";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                value: selectedActivity,
                hint: Text("Select Activity"),
                items: activities.map<DropdownMenuItem<String>>((
                  String activity,
                ) {
                  return DropdownMenuItem<String>(
                    value: activity,
                    child: Text(activity),
                  );
                }).toList(),
                onChanged: (String? newvalue) {
                  setState(() {
                    selectedActivity = newvalue;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        ReminderModel reminder = ReminderModel(
                          day: "$selectedDay",
                          time: formattedTime,
                          activity: "$selectedActivity",
                        );
                        reminders.add(reminder);
                        await ReminderStorage.saveReminders(reminders);

                        // Schedule notification (fixed here)
                        if (selectedDay != null &&
                            selectedTime != null &&
                            selectedActivity != null) {
                          // final scheduledDate = _nextInstanceOfDayTime(
                          //   selectedDay!,
                          //   selectedTime!,
                          // );
                          // await scheduleNotification(
                          //   'Reminder for $selectedActivity',
                          //   'It\'s time for your activity!',
                          //   scheduledDate,
                          // );
                        }

                        setState(() {
                          selectedDay = null;
                          selectedTime = null;
                          _selectedTimeText = "Select Time";
                          selectedActivity = null;
                        });
                      }
                      setState(() {});
                      print("list:${reminders.length}");
                    },
                    child: Text("Add Reminder"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      NotificationService().showNotification(
                        title: "title",
                        body: "body",
                      );
                    },
                    child: Text("Show noti"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: reminders.isEmpty
                    ? Center(
                        child: Text("No Reminder's \n Please add Remndeer's"),
                      )
                    : ListView.builder(
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = reminders[index];
                          return Card(
                            child: ListTile(
                              title: Text("${reminder.day} - ${reminder.time}"),
                              subtitle: Text(reminder.activity),
                              leading: Icon(
                                Icons.alarm,
                                color: Colors.deepPurple,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    reminders.removeAt(index);
                                    ReminderStorage.saveReminders(reminders);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
