import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mood_tracker/constant/app_colors.dart';

/// Animated card showing current consecutive mood logging streak.
class StreakCounter extends StatelessWidget {
  /// Creates streak counter with required [value].
  const StreakCounter({super.key, required this.value});

  /// Number of consecutive days with at least one mood entry.
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.accent),
          const SizedBox(height: 12),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(seconds: 1),
            builder: (context, animatedValue, child) {
              return Text(
                animatedValue.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              );
            },
          ),
          const Text('Day streak', style: TextStyle(color: AppColors.inkSoft)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.14);
  }
}
