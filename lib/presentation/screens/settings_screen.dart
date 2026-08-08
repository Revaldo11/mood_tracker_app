import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constant/app_colors.dart';
import '../../data/models/notification_settings_model.dart';
import '../../data/sources/local_database.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../services/notification_service.dart';
import '../widgets/notification_preview.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final NotificationRepository _repository;
  late Future<NotificationSettingsModel> _settings;

  @override
  void initState() {
    super.initState();
    _repository = NotificationRepository(Get.find<LocalDatabase>());
    _reload();
  }

  void _reload() {
    _settings = _repository.getNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder<NotificationSettingsModel>(
        future: _settings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final settings = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Daily Mood Reminder'),
                  subtitle: const Text('Get a notification to log your mood'),
                  value: settings.isEnabled,
                  onChanged: (enabled) => _toggleReminder(enabled),
                ),
              ),
              if (settings.isEnabled) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: const Text('Reminder Time'),
                    subtitle: Text(_formattedTime(settings.reminderTime)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(settings),
                  ),
                ),
                const SizedBox(height: 12),
                NotificationPreview(reminderTime: settings.reminderTime),
              ],
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Last Reminder Sent'),
                  subtitle: Text(
                    settings.lastNotificationSentAt == null
                        ? 'No notification sent yet'
                        : DateFormat('d MMM yyyy, HH:mm').format(
                            settings.lastNotificationSentAt!,
                          ),
                  ),
                  trailing: settings.lastNotificationSentAt == null
                      ? null
                      : IconButton(
                          tooltip: 'Clear history',
                          onPressed: _clearHistory,
                          icon: const Icon(Icons.delete_outline),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _sendTestNotification,
                icon: const Icon(Icons.notification_add_outlined),
                label: const Text('Send Test Notification'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reminders are stored and scheduled only on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkSoft),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleReminder(bool enabled) async {
    if (enabled && !await NotificationService.instance.requestPermission()) {
      _showMessage('Notification permission is required.');
      return;
    }
    await _repository.toggleNotification(enabled);
    if (!mounted) {
      return;
    }
    setState(_reload);
    _showMessage(enabled ? 'Daily reminder enabled.' : 'Daily reminder disabled.');
  }

  Future<void> _selectTime(NotificationSettingsModel settings) async {
    final parts = settings.reminderTime.split(':');
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
      helpText: 'Select reminder time',
    );
    if (selected == null) {
      return;
    }
    final time = '${selected.hour.toString().padLeft(2, '0')}:'
        '${selected.minute.toString().padLeft(2, '0')}';
    await _repository.setReminderTime(time);
    if (!mounted) {
      return;
    }
    setState(_reload);
    _showMessage('Reminder time updated.');
  }

  Future<void> _sendTestNotification() async {
    if (!await NotificationService.instance.requestPermission()) {
      _showMessage('Notification permission is required.');
      return;
    }
    await NotificationService.instance.showMoodReminder(
      _repository,
      isTest: true,
    );
    if (!mounted) {
      return;
    }
    setState(_reload);
    _showMessage('Test notification sent.');
  }

  Future<void> _clearHistory() async {
    await _repository.clearNotificationHistory();
    if (!mounted) {
      return;
    }
    setState(_reload);
    _showMessage('Notification history cleared.');
  }

  String _formattedTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    ).format(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
