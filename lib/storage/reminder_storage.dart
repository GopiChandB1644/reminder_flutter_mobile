//reminderstorage
//import 'package:reminder_app/model/reminder_model.dart';
import 'package:reminderapp/model/reminder_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderStorage {
  static const String remindersKey = "reminders";

  static Future<void> saveReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = reminders
        .map((reminder) => reminder.toJson())
        .toList();

    await prefs.setStringList(remindersKey, jsonList);
  }

  static Future<List<ReminderModel>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? jsonList = prefs.getStringList(remindersKey);

    if (jsonList != null) {
      return jsonList
          .map((jsonStr) => ReminderModel.fromJson(jsonStr))
          .toList();
    }
    return [];
  }

  static Future<void> clearReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(remindersKey);
  }
}
