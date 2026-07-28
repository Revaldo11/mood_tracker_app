import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFE8FFF2),
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
                            style: TextStyle(color: Color(0xFF637381)),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE4E7EC)),
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
              border: Border.all(color: const Color(0xFFE4E7EC)),
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
                        style: TextStyle(color: Color(0xFF637381)),
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
              color: const Color(0xFFF2F4F7),
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
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6BCB77)),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(title, style: const TextStyle(color: Color(0xFF637381))),
        ],
      ),
    );
  }
}
