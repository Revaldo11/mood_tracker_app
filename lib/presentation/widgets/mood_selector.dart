import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../controllers/mood_controller.dart';

/// Reactive mood option selector used in journaling flows.
///
/// Binds directly to [MoodController.selectedMood].
///
/// Example:
/// ```dart
/// const MoodSelector()
/// ```
class MoodSelector extends GetView<MoodController> {
  /// Creates the mood selector widget.
  const MoodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.moods.map((option) {
          final selected = controller.selectedMood.value == option.value;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.selectMood(option);
            },
            child: AnimatedScale(
              scale: selected ? 1.18 : 0.92,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? option.color.withValues(alpha: 0.24)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? option.color : const Color(0xFFE4E7EC),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: option.color.withValues(alpha: 0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ).animate(target: selected ? 1 : 0).shake(
                  duration: 260.ms,
                  hz: 3,
                  rotation: 0.02,
                ),
          );
        }).toList(),
      ),
    );
  }
}
