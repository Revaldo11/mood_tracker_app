import 'package:flutter/material.dart';

import '../../constant/app_colors.dart';

class NotificationPreview extends StatelessWidget {
  const NotificationPreview({
    super.key,
    required this.reminderTime,
  });

  final String reminderTime;

  @override
  Widget build(BuildContext context) {
    final parts = reminderTime.split(':');
    final time = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    ).format(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paperDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Time to log your mood! 😊',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Text('How are you feeling today?'),
                const SizedBox(height: 4),
                Text(
                  'Reminder at $time',
                  style: const TextStyle(color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
