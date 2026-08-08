import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker/data/models/notification_settings_model.dart';

void main() {
  test('NotificationSettingsModel copyWith preserves unchanged values', () {
    final settings = NotificationSettingsModel.defaults(
      timezone: 'Asia/Jakarta',
    );

    final updated = settings.copyWith(
      isEnabled: true,
      reminderTime: '14:30',
    );

    expect(updated.isEnabled, isTrue);
    expect(updated.reminderTime, '14:30');
    expect(updated.timezone, 'Asia/Jakarta');
    expect(updated.skipIfLogged, isTrue);
  });

  test('NotificationSettingsModel persists notification history', () {
    final sentAt = DateTime(2026, 8, 8, 9);
    final settings = NotificationSettingsModel.defaults(
      timezone: 'Asia/Jakarta',
    ).copyWith(lastNotificationSentAt: sentAt);

    final restored = NotificationSettingsModel.fromMap(settings.toMap());

    expect(restored.lastNotificationSentAt, sentAt);
    expect(restored.notificationId, 0);
  });
}
