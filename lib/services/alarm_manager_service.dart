import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../data/sources/local_database.dart';
import '../domain/repositories/notification_repository.dart';
import 'notification_service.dart';

class AlarmManagerService {
  static const alarmId = 0;

  static Future<void> scheduleAlarm({required String reminderTime}) async {
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

    await AndroidAlarmManager.cancel(alarmId);
    await AndroidAlarmManager.oneShotAt(
      scheduledDate,
      alarmId,
      showMoodReminderAlarm,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> cancelAlarm() async {
    await AndroidAlarmManager.cancel(alarmId);
  }
}

@pragma('vm:entry-point')
Future<void> showMoodReminderAlarm() async {
  final database = await LocalDatabase.init();
  final repository = NotificationRepository(database);
  await NotificationService.instance.initNotifications();
  await NotificationService.instance.showMoodReminder(repository);
  await repository.scheduleNotificationIfEnabled();
}
