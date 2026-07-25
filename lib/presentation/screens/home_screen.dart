import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/mood_controller.dart';
import '../widgets/mood_selector.dart';

/// Primary journaling screen for recording today's mood.
///
/// Provides mood selection, optional notes input, save action, and a short
/// recent-history preview.
class HomeScreen extends GetView<MoodController> {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 12),
              Text(
                _greeting(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2933),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF637381),
                    ),
              ),
              const SizedBox(height: 28),
              Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              const MoodSelector(),
              const SizedBox(height: 24),
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: controller.isNotesFocused.value
                            ? const Color(0xFF6BCB77).withValues(alpha: 0.24)
                            : Colors.transparent,
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.notesController,
                    focusNode: controller.notesFocusNode,
                    maxLines: 5,
                    maxLength: 180,
                    decoration: InputDecoration(
                      hintText: 'Write a short note...',
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF6BCB77),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await controller.saveMood();
                  },
                  icon: const Icon(Icons.celebration_outlined),
                  label: const Text('Save Mood'),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Recent mood',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Obx(
                () {
                  if (controller.recentEntries.isEmpty) {
                    return _EmptyHistory();
                  }

                  return Column(
                    children: controller.recentEntries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE4E7EC)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              entry.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEE, d MMM').format(entry.timestamp),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (entry.notes.isNotEmpty)
                                    Text(
                                      entry.notes,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF637381),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.12);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller.confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 24,
            gravity: 0.18,
            colors: const [
              Color(0xFFFF6B6B),
              Color(0xFFFFA500),
              Color(0xFFFFD700),
              Color(0xFF98D8C8),
              Color(0xFF6BCB77),
            ],
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: const Text(
        'No mood entries yet.',
        style: TextStyle(color: Color(0xFF637381)),
      ),
    );
  }
}
