import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/models/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';

class MoodController extends GetxController {
  MoodController(this._repository);

  final MoodRepository _repository;
  final notesController = TextEditingController();
  final notesFocusNode = FocusNode();
  final confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  final entries = <MoodEntry>[].obs;
  final selectedMood = 4.obs;
  final selectedEmoji = '🙂'.obs;
  final selectedTab = 0.obs;
  final isNotesFocused = false.obs;
  final touchedChartDate = Rxn<DateTime>();

  final moods = const [
    MoodOption(1, '😢', Color(0xFFFF6B6B), 'Sad'),
    MoodOption(2, '😕', Color(0xFFFFA500), 'Meh'),
    MoodOption(3, '😐', Color(0xFFFFD700), 'Neutral'),
    MoodOption(4, '🙂', Color(0xFF98D8C8), 'Good'),
    MoodOption(5, '😊', Color(0xFF6BCB77), 'Happy'),
  ];

  @override
  void onInit() {
    super.onInit();
    notesFocusNode.addListener(() {
      isNotesFocused.value = notesFocusNode.hasFocus;
    });
    loadEntries();
  }

  Future<void> loadEntries() async {
    entries.assignAll(await _repository.getEntries());
    _selectPreviousMoodSuggestion();
  }

  void selectMood(MoodOption option) {
    selectedMood.value = option.value;
    selectedEmoji.value = option.emoji;
  }

  Future<void> saveMood() async {
    final entry = MoodEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      mood: selectedMood.value,
      notes: notesController.text.trim(),
      timestamp: DateTime.now(),
      emoji: selectedEmoji.value,
    );

    await _repository.saveEntry(entry);
    notesController.clear();
    confettiController.play();
    await loadEntries();

    if (!Get.testMode) {
      Get.snackbar(
        'Mood saved',
        'Your daily mood has been recorded.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    }
  }

  List<MoodEntry> get recentEntries => entries.take(3).toList();

  List<MoodEntry> get lastSevenDaysEntries {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));

    return entries.where((entry) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      return !date.isBefore(start);
    }).toList();
  }

  int get currentStreak {
    var streak = 0;
    var day = DateTime.now();
    final loggedDays = entries
        .map((entry) => DateFormat('yyyy-MM-dd').format(entry.timestamp))
        .toSet();

    while (loggedDays.contains(DateFormat('yyyy-MM-dd').format(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  MoodOption get mostCommonMood {
    if (entries.isEmpty) {
      return moods[3];
    }

    final counts = <int, int>{};
    for (final entry in entries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }

    final mood = counts.entries.reduce(
      (current, next) => next.value > current.value ? next : current,
    );

    return moods.firstWhere((option) => option.value == mood.key);
  }

  MoodOption moodOptionByValue(int value) {
    return moods.firstWhere((option) => option.value == value);
  }

  MoodEntry? entryForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return entries.firstWhereOrNull(
      (entry) => DateFormat('yyyy-MM-dd').format(entry.timestamp) == key,
    );
  }

  void _selectPreviousMoodSuggestion() {
    if (entries.isEmpty) {
      return;
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final entry = entryForDate(yesterday) ?? entries.first;
    final option = moodOptionByValue(entry.mood);
    selectedMood.value = option.value;
    selectedEmoji.value = option.emoji;
  }

  @override
  void onClose() {
    notesController.dispose();
    notesFocusNode.dispose();
    confettiController.dispose();
    super.onClose();
  }
}

class MoodOption {
  const MoodOption(this.value, this.emoji, this.color, this.label);

  final int value;
  final String emoji;
  final Color color;
  final String label;
}
