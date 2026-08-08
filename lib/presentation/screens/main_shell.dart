import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/mood_controller.dart';
import '../../services/notification_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Main post-splash shell with bottom navigation between feature tabs.
///
/// Example:
/// ```dart
/// Get.off(() => const MainShell());
/// ```
class MainShell extends GetView<MoodController> {
  /// Creates the main shell screen.
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.consumePendingMoodLogging();
      if (controller.shouldShowWarning()) {
        controller.showDataWarningDialog();
      }
    });
    
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedTab.value,
          children: const [
            HomeScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedTab.value,
          onDestinationSelected: (index) {
            controller.selectedTab.value = index;
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
