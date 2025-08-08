//Reminder model
import 'dart:convert';

class ReminderModel {
  final String day;
  final String time;
  final String activity;
  ReminderModel({
    required this.day,
    required this.time,
    required this.activity,
  });

  Map<String, dynamic> toMap() {
    return {"day": day, "time": time, "activity": activity};
  }

  factory ReminderModel.fromMap(Map<String, dynamic> json) {
    return ReminderModel(
      day: json["day"],
      time: json["time"],
      activity: json["activity"],
    );
  }
  String toJson() => jsonEncode(toMap());
  factory ReminderModel.fromJson(String source) =>
      ReminderModel.fromMap(jsonDecode(source));
}
