import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminderapp/model/reminder_model.dart';
import 'package:reminderapp/notification/notification_service.dart';
import 'package:reminderapp/storage/reminder_storage.dart';
import 'package:permission_handler/permission_handler.dart';

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
    'Sunday',
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

    // Load existing reminders
    ReminderStorage.getReminders().then((loadedReminders) {
      setState(() {
        reminders = loadedReminders;
      });
    });

    //  REQUEST PERMISSION ON APP START
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermission();
    });
  }

  //  ADD THIS METHOD
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print('Notification permission granted');
      } else if (result.isPermanentlyDenied) {
        // Show dialog to open settings
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notification Permission Required'),
        content: Text(
          'Please enable notifications in app settings to receive reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

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
    return DateFormat.jm().format(dt); 
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
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      // CHECK PERMISSION FIRST
                      final hasPermission =
                          await Permission.notification.status;

                      if (!hasPermission.isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please allow notifications to set reminders',
                            ),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'Allow',
                              onPressed: () async {
                                await Permission.notification.request();
                              },
                            ),
                          ),
                        );
                        return;
                      }
                      final notificationId = _generateNotificationId();

                      ReminderModel reminder = ReminderModel(
                        day: selectedDay!,
                        time: formattedTime,
                        activity: selectedActivity!,
                        notificationId: notificationId,
                      );

                      try {
                        await NotificationService().scheduleNotificationForDay(
                          id: notificationId,
                          title: "Reminder: $selectedActivity",
                          body: "Time for $selectedActivity!",
                          dayName: selectedDay!,
                          hour: selectedTime!.hour,
                          minute: selectedTime!.minute,
                        );

                        reminders.add(reminder);
                        await ReminderStorage.saveReminders(reminders);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reminder scheduled successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        setState(() {
                          selectedDay = null;
                          selectedTime = null;
                          _selectedTimeText = "Select Time";
                          selectedActivity = null;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to schedule reminder: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text("Add Reminder"),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: reminders.isEmpty
                    ? Center(child: Text("No Reminders \nPlease add Reminders"))
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
                                onPressed: () async {
                                  // Cancel the notification before removing the reminder
                                  await NotificationService()
                                      .cancelNotification(
                                        reminder.notificationId,
                                      );

                                  setState(() {
                                    reminders.removeAt(index);
                                  });

                                  await ReminderStorage.saveReminders(
                                    reminders,
                                  );

                                  //  Show confirmation message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Reminder deleted and notification cancelled',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
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
