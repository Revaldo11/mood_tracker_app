import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakCounter extends StatelessWidget {
  const StreakCounter({super.key, required this.value});

  final int value;

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
          const Icon(Icons.local_fire_department, color: Color(0xFFFFA500)),
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
          const Text('Day streak', style: TextStyle(color: Color(0xFF637381))),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.14);
  }
}
