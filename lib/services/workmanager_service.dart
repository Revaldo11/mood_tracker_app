import 'package:workmanager/workmanager.dart';

class WorkManagerService {
  static const taskName = 'moodReminderTask';

  static Future<void> scheduleReminder({required String reminderTime}) async {
    final parts = reminderTime.split(':');
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await Workmanager().cancelByUniqueName(taskName);
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(days: 1),
      initialDelay: scheduledDate.difference(now),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }

  static Future<void> cancelReminder() async {
    await Workmanager().cancelByUniqueName(taskName);
  }
}
