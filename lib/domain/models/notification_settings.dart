class NotificationSettings {
  const NotificationSettings({
    required this.id,
    required this.isEnabled,
    required this.reminderTime,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
    required this.skipIfLogged,
    required this.notificationId,
    this.lastNotificationSentAt,
    this.wasLoggedAfterNotification,
    this.retryCount = 0,
    this.nextScheduledTime,
  });

  final String id;
  final bool isEnabled;
  final String reminderTime;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool skipIfLogged;
  final int notificationId;
  final DateTime? lastNotificationSentAt;
  final bool? wasLoggedAfterNotification;
  final int retryCount;
  final DateTime? nextScheduledTime;
}
