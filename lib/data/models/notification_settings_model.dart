import '../../domain/models/notification_settings.dart';

class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    required super.id,
    required super.isEnabled,
    required super.reminderTime,
    required super.timezone,
    required super.createdAt,
    required super.updatedAt,
    required super.skipIfLogged,
    required super.notificationId,
    super.lastNotificationSentAt,
    super.wasLoggedAfterNotification,
    super.retryCount,
    super.nextScheduledTime,
  });

  factory NotificationSettingsModel.defaults({required String timezone}) {
    final now = DateTime.now();
    return NotificationSettingsModel(
      id: 'notification_settings',
      isEnabled: false,
      reminderTime: '09:00',
      timezone: timezone,
      createdAt: now,
      updatedAt: now,
      skipIfLogged: true,
      notificationId: 0,
    );
  }

  factory NotificationSettingsModel.fromMap(Map<dynamic, dynamic> map) {
    return NotificationSettingsModel(
      id: map['id'] as String,
      isEnabled: map['isEnabled'] as bool,
      reminderTime: map['reminderTime'] as String,
      timezone: map['timezone'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      skipIfLogged: map['skipIfLogged'] as bool,
      notificationId: map['notificationId'] as int,
      lastNotificationSentAt: map['lastNotificationSentAt'] == null
          ? null
          : DateTime.parse(map['lastNotificationSentAt'] as String),
      wasLoggedAfterNotification: map['wasLoggedAfterNotification'] as bool?,
      retryCount: map['retryCount'] as int? ?? 0,
      nextScheduledTime: map['nextScheduledTime'] == null
          ? null
          : DateTime.parse(map['nextScheduledTime'] as String),
    );
  }

  NotificationSettingsModel copyWith({
    bool? isEnabled,
    String? reminderTime,
    String? timezone,
    DateTime? lastNotificationSentAt,
    bool? wasLoggedAfterNotification,
    int? retryCount,
    DateTime? nextScheduledTime,
  }) {
    return NotificationSettingsModel(
      id: id,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      skipIfLogged: skipIfLogged,
      notificationId: notificationId,
      lastNotificationSentAt:
          lastNotificationSentAt ?? this.lastNotificationSentAt,
      wasLoggedAfterNotification:
          wasLoggedAfterNotification ?? this.wasLoggedAfterNotification,
      retryCount: retryCount ?? this.retryCount,
      nextScheduledTime: nextScheduledTime ?? this.nextScheduledTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isEnabled': isEnabled,
      'reminderTime': reminderTime,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'skipIfLogged': skipIfLogged,
      'notificationId': notificationId,
      'lastNotificationSentAt': lastNotificationSentAt?.toIso8601String(),
      'wasLoggedAfterNotification': wasLoggedAfterNotification,
      'retryCount': retryCount,
      'nextScheduledTime': nextScheduledTime?.toIso8601String(),
    };
  }
}
