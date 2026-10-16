import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mood_tracker/constant/app_colors.dart';
import 'package:mood_tracker/shared/dialog.dart';
import 'package:intl/intl.dart';

import '../../domain/models/mood_entry.dart';
import '../controllers/backup_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/mood_controller.dart';
import '../widgets/mood_chart.dart';
import '../widgets/streak_counter.dart';
import '../widgets/wave_background.dart';
import 'auth_screen.dart';

/// Statistics/profile screen for viewing mood trends and history.
class ProfileScreen extends GetView<MoodController> {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final backupController = Get.find<BackupController>();
    backupController.refreshForCurrentUser();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Stack(
            children: [
              const Positioned.fill(child: WaveBackground()),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: MoodColors.good.withValues(alpha: 0.2),
                      child: Text('😊', style: TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authController.currentUser?.username ??
                                'Your Mood Insights',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your emotional journey at a glance',
                            style: TextStyle(color: AppColors.inkSoft),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final shouldLogout = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Apakah Anda yakin ingin logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout != true) {
                          return;
                        }

                        await authController.logout();
                        Get.offAll(
                          () => const AuthScreen(),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      icon: Icon(Icons.settings_outlined, size: 30,),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.15),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: StreakCounter(value: controller.currentStreak),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.edit_note,
                    title: 'Entries',
                    value: controller.entries.length.toString(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () {
              final email = backupController.connectedEmail.value;
              final lastBackup = backupController.lastBackupAt.value;
              final isLoading = backupController.isLoading.value;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Drive Backup',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email ?? 'Connect Google Drive to protect your mood data.',
                      style: const TextStyle(color: AppColors.inkSoft),
                    ),
                    if (lastBackup != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Last backup: ${DateFormat('d MMM yyyy, HH:mm').format(lastBackup.toLocal())}',
                        style: const TextStyle(color: AppColors.inkSoft),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (email == null)
                      FilledButton.icon(
                        onPressed: () => _connectDrive(backupController),
                        icon: const Icon(Icons.cloud_outlined),
                        label: const Text('Connect Google Drive'),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _backupToDrive(backupController),
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: const Text('Backup'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _restoreFromDrive(backupController),
                              icon: const Icon(Icons.cloud_download_outlined),
                              label: const Text('Restore'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Last 7 days',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Obx(
                      () {
                        final mood = controller.mostCommonMood;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: mood.color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${mood.emoji} ${mood.label}'),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const SizedBox(height: 220, child: MoodChart()),
              ],
            ),
          ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.14),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood Timeline',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () {
                    if (controller.entries.isEmpty) {
                      return const Text(
                        'Start logging your mood to see history here.',
                        style: TextStyle(color: AppColors.inkSoft),
                      );
                    }

                    return Column(
                      children: controller.entries.map((entry) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            entry.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                          title: Text(
                            DateFormat('EEE, d MMM yyyy').format(entry.timestamp),
                          ),
                          subtitle: entry.notes.isEmpty ? null : Text(entry.notes),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'edit') {
                                _showEditMoodDialog(entry);
                              } else {
                                _confirmDeleteMood(entry);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.paperDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium_outlined),
                SizedBox(width: 12),
                Expanded(child: Text('Achievement badges coming soon')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditMoodDialog(
    MoodEntry entry,
  ) async {
    final notesController = TextEditingController(text: entry.notes);
    var selectedMood = controller.moodOptionByValue(entry.mood);

    final mood = await Get.dialog<MoodOption>(
      AlertDialog(
        title: const Text('Edit mood'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<MoodOption>(
                  value: selectedMood,
                  decoration: const InputDecoration(labelText: 'Mood'),
                  items: controller.moods
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text('${option.emoji} ${option.label}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedMood = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  maxLength: 180,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: selectedMood),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final notes = notesController.text;
    notesController.dispose();
    if (mood == null) {
      return;
    }

    await controller.updateMood(
      entry,
      mood: mood,
      notes: notes,
    );
  }

  Future<void> _confirmDeleteMood(
    MoodEntry entry,
  ) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete mood?'),
        content: const Text('This mood entry will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    await controller.removeMood(entry.id);
  }

  Future<void> _connectDrive(BackupController backupController) async {
    final success = await backupController.connect();
    if (!success) {
      await showDialogWarning(
        backupController.errorMessage.value ??
            'Unable to connect Google Drive.',
        title: 'Google Drive connection failed',
      );
      return;
    }

    Get.snackbar(
      'Google Drive connected',
      'Your mood data can now be backed up.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  Future<void> _backupToDrive(BackupController backupController) async {
    final success = await backupController.backup();
    if (!success) {
      await showDialogWarning(
        backupController.errorMessage.value ?? 'Unable to back up mood data.',
        title: 'Backup failed',
      );
      return;
    }

    Get.snackbar(
      'Backup complete',
      'Your mood data was saved to Google Drive.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  Future<void> _restoreFromDrive(BackupController backupController) async {
    final success = await backupController.restore();
    if (!success) {
      await showDialogWarning(
        backupController.errorMessage.value ??
            'Unable to restore mood data.',
        title: 'Restore failed',
      );
      return;
    }

    Get.snackbar(
      'Restore complete',
      'Mood data was merged from Google Drive.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(title, style: const TextStyle(color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}
