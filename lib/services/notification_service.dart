import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../domain/repositories/notification_repository.dart';
import '../presentation/controllers/mood_controller.dart';
import '../presentation/screens/main_shell.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static const channelId = 'mood_reminder_channel';
  static const payload = 'moodReminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _pendingMoodLogging = false;

  Future<void> initNotifications() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    const channel = AndroidNotificationChannel(
      channelId,
      'Mood Reminder',
      description: 'Daily mood reminder notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _pendingMoodLogging = launchDetails?.notificationResponse?.payload == payload;
    }
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    return await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        true;
  }

  Future<void> showMoodReminder(
    NotificationRepository repository, {
    bool isTest = false,
  }) async {
    final settings = await repository.getNotificationSettings();
    if (!isTest && !settings.isEnabled) {
      return;
    }
    if (!isTest &&
        settings.lastNotificationSentAt != null &&
        DateTime.now().difference(settings.lastNotificationSentAt!).inMinutes < 5) {
      return;
    }
    if (!isTest && settings.skipIfLogged && await repository.hasLoggedToday()) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      channelId,
      'Mood Reminder',
      channelDescription: 'Daily mood reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      actions: [
        AndroidNotificationAction(
          'log_mood',
          'Log Now',
          cancelNotification: true,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'dismiss',
          'Dismiss',
          cancelNotification: true,
        ),
      ],
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      settings.notificationId,
      'Time to log your mood! 😊',
      'How are you feeling today?',
      details,
      payload: payload,
    );
    await repository.updateLastNotificationTime();
  }

  void consumePendingMoodLogging() {
    if (!_pendingMoodLogging || !Get.isRegistered<MoodController>()) {
      return;
    }
    _pendingMoodLogging = false;
    _openMoodLogging();
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.actionId == 'dismiss') {
      return;
    }
    if (response.payload != payload) {
      return;
    }
    if (!Get.isRegistered<MoodController>()) {
      _pendingMoodLogging = true;
      return;
    }
    _openMoodLogging();
  }

  void _openMoodLogging() {
    final controller = Get.find<MoodController>();
    controller.selectedTab.value = 0;
    Get.offAll(() => const MainShell());
    Future.delayed(const Duration(milliseconds: 350), () {
      controller.notesFocusNode.requestFocus();
    });
  }
}
