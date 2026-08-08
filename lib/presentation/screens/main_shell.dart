import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mood_tracker/constant/app_colors.dart';

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
        extendBody: true,
        body: IndexedStack(
          index: controller.selectedTab.value,
          children: const [
            HomeScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.28
                        : 0.12,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.nightDim.withValues(alpha: 0.78)
                        : AppColors.paper.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.mist.withValues(alpha: 0.14)
                          : Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  child: Row(
                    children: [
                      _NavigationItem(
                        label: 'Today',
                        icon: Icons.edit_note_outlined,
                        selectedIcon: Icons.edit_note,
                        selected: controller.selectedTab.value == 0,
                        onTap: () => controller.selectedTab.value = 0,
                      ),
                      _NavigationItem(
                        label: 'Profile',
                        icon: Icons.bar_chart_outlined,
                        selectedIcon: Icons.bar_chart,
                        selected: controller.selectedTab.value == 1,
                        onTap: () => controller.selectedTab.value = 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.mist
        : AppColors.ink;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      selected ? selectedIcon : icon,
                      key: ValueKey(selected),
                      size: 25,
                      color: selected ? AppColors.accent : foregroundColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      color: selected
                          ? foregroundColor
                          : foregroundColor.withValues(alpha: 0.72),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
