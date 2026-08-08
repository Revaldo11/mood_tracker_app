import 'package:flutter_timezone/flutter_timezone.dart';

import '../../data/models/notification_settings_model.dart';
import '../../data/sources/local_database.dart';
import '../../services/alarm_manager_service.dart';
import '../../services/workmanager_service.dart';

class NotificationRepository {
  NotificationRepository(this._database);

  final LocalDatabase _database;

  Future<NotificationSettingsModel> getNotificationSettings() async {
    final stored = _database.notificationSettings;
    if (stored != null) {
      return NotificationSettingsModel.fromMap(stored);
    }

    final settings = NotificationSettingsModel.defaults(
      timezone: (await FlutterTimezone.getLocalTimezone()).identifier,
    );
    await saveNotificationSettings(settings);
    return settings;
  }

  Future<void> saveNotificationSettings(
    NotificationSettingsModel settings,
  ) async {
    await _database.saveNotificationSettings(settings.toMap());
  }

  Future<void> toggleNotification(bool enabled) async {
    final settings = await getNotificationSettings();
    await saveNotificationSettings(settings.copyWith(isEnabled: enabled));
    if (enabled) {
      await scheduleNotificationIfEnabled();
    } else {
      await cancelNotification();
    }
  }

  Future<void> setReminderTime(String time) async {
    final settings = await getNotificationSettings();
    await saveNotificationSettings(settings.copyWith(reminderTime: time));
    if (settings.isEnabled) {
      await scheduleNotificationIfEnabled();
    }
  }

  Future<void> scheduleNotificationIfEnabled() async {
    var settings = await getNotificationSettings();
    if (!settings.isEnabled) {
      return;
    }

    final timezone = (await FlutterTimezone.getLocalTimezone()).identifier;
    if (timezone != settings.timezone) {
      settings = settings.copyWith(timezone: timezone);
      await saveNotificationSettings(settings);
    }

    final nextScheduledTime = _nextOccurrence(settings.reminderTime);
    await WorkManagerService.scheduleReminder(
      reminderTime: settings.reminderTime,
    );
    await AlarmManagerService.scheduleAlarm(
      reminderTime: settings.reminderTime,
    );
    await saveNotificationSettings(
      settings.copyWith(nextScheduledTime: nextScheduledTime),
    );
  }

  Future<void> cancelNotification() async {
    await WorkManagerService.cancelReminder();
    await AlarmManagerService.cancelAlarm();
  }

  Future<bool> hasLoggedToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final entries = await _database.getEntries();
    return entries.any(
      (entry) => !entry.timestamp.isBefore(start) && entry.timestamp.isBefore(end),
    );
  }

  Future<void> updateLastNotificationTime() async {
    final settings = await getNotificationSettings();
    await saveNotificationSettings(
      settings.copyWith(lastNotificationSentAt: DateTime.now()),
    );
  }

  Future<void> clearNotificationHistory() async {
    final settings = await getNotificationSettings();
    await saveNotificationSettings(
      NotificationSettingsModel(
        id: settings.id,
        isEnabled: settings.isEnabled,
        reminderTime: settings.reminderTime,
        timezone: settings.timezone,
        createdAt: settings.createdAt,
        updatedAt: DateTime.now(),
        skipIfLogged: settings.skipIfLogged,
        notificationId: settings.notificationId,
        retryCount: settings.retryCount,
        nextScheduledTime: settings.nextScheduledTime,
      ),
    );
  }

  DateTime _nextOccurrence(String reminderTime) {
    final parts = reminderTime.split(':');
    final now = DateTime.now();
    var date = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (!date.isAfter(now)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}
