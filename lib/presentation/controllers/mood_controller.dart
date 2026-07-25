import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/constant/constant.dart';
import 'package:mood_tracker/shared/dialog/data_warning_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';

/// GetX controller coordinating mood journaling state and persistence.
///
/// Responsibilities:
/// - Keeps UI state for mood selection, notes, tabs, and chart interaction.
/// - Loads/saves mood entries through [MoodRepository].
/// - Manages data-warning preference in `SharedPreferences`.
///
/// Example:
/// ```dart
/// final controller = Get.find<MoodController>();
/// controller.selectMood(controller.moods.last);
/// await controller.saveMood();
/// ```
class MoodController extends GetxController {
  /// Creates controller with injected persistence [MoodRepository].
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

  /// Loads all entries from repository and updates suggestion state.
  ///
  /// Side effects:
  /// - Updates [entries], [selectedMood], and [selectedEmoji].
  ///
  /// Throws:
  /// - Propagates repository read errors.
  Future<void> loadEntries() async {
    entries.assignAll(await _repository.getEntries());
    _selectPreviousMoodSuggestion();
  }

  /// Updates currently selected mood option.
  void selectMood(MoodOption option) {
    selectedMood.value = option.value;
    selectedEmoji.value = option.emoji;
  }

  /// Creates and stores a mood entry from current form state.
  ///
  /// Parameters:
  /// - [title]: Snackbar title after save.
  /// - [message]: Snackbar message after save.
  ///
  /// Side effects:
  /// - Writes to repository.
  /// - Clears notes field.
  /// - Triggers confetti animation.
  /// - Reloads entries list from storage.
  /// - Displays snackbar when not in test mode.
  ///
  /// Throws:
  /// - Propagates repository write/read errors.
  /// 
  final RxBool isLoadingSubmit = false.obs;

  Future<void> saveMood({
    String title = 'Mood saved',
    String message = 'Your daily mood has been recorded.',
  }) async {
    if (isLoadingSubmit.value) return;

    isLoadingSubmit.value = true;

    try {
      final entry = MoodEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        mood: selectedMood.value,
        notes: notesController.text.trim(),
        timestamp: DateTime.now(),
        emoji: selectedEmoji.value,
      );

      // Simulate saving process (minimum 1 second)
      await Future.delayed(const Duration(seconds: 1));

      await _repository.saveEntry(entry);

      notesController.clear();
      confettiController.play();
      await loadEntries();

      if (!Get.testMode) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );
      }

    } finally {
      isLoadingSubmit.value = false;
    }
  }

  Future<void> removeMood(
    String id, {
    String title = 'Mood removed',
    String message = 'Your mood entry has been removed.',
  }) async {
    await _repository.removeEntry(id);
    await loadEntries();

    if (!Get.testMode) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Returns up to three most recent entries.
  List<MoodEntry> get recentEntries => entries.take(3).toList();

  /// Returns entries from the last seven calendar days (inclusive).
  List<MoodEntry> get lastSevenDaysEntries {
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));

    return entries.where((entry) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      return !date.isBefore(start);
    }).toList();
  }

  /// Calculates consecutive day streak ending today.
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

  /// Returns the most frequently selected mood in current dataset.
  ///
  /// Returns a default "Good" mood option when no entries exist.
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

  /// Maps numeric mood [value] to its [MoodOption].
  ///
  /// Throws:
  /// - [StateError] when no matching option exists.
  MoodOption moodOptionByValue(int value) {
    return moods.firstWhere((option) => option.value == value);
  }

  /// Finds entry recorded on the provided calendar [date].
  ///
  /// Returns `null` when no entry exists for that day.
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

  final RxBool dataWarningShown = false.obs;

  /// Loads "data warning shown" flag from shared preferences.
  ///
  /// Side effects:
  /// - Updates [dataWarningShown].
  ///
  /// Errors:
  /// - Catches and logs preference access errors without rethrowing.
  Future<void> loadDataWarningStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool shown = prefs.getBool(DATA_WARNING_SHOWN_KEY) ?? false;
      dataWarningShown.value = shown;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data warning status: $e');
      }
    }
  }

  /// Persists data warning as shown.
  ///
  /// Side effects:
  /// - Writes boolean flag to `SharedPreferences`.
  /// - Updates [dataWarningShown].
  ///
  /// Errors:
  /// - Catches and logs preference write errors without rethrowing.
  Future<void> markDataWarningAsShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(DATA_WARNING_SHOWN_KEY, true);
      dataWarningShown.value = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving data warning status: $e');
      }
    }
  }

  /// Returns whether data warning dialog should be shown.
  bool shouldShowWarning() {
    return !dataWarningShown.value;
  }

  /// Presents non-dismissible data warning dialog when no dialog is open.
  ///
  /// Side effects:
  /// - Pushes a dialog route via GetX navigation.
  void showDataWarningDialog() {
    if (Get.isDialogOpen ?? false) {
      return;
    }

    Get.dialog(
      const DataWarningDialog(),
      barrierDismissible: false,
      transitionCurve: Curves.easeInOutCubic,
      transitionDuration: Duration(milliseconds: 500),
    );
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
  /// Creates a mood option used by selectors and statistics UI.
  const MoodOption(this.value, this.emoji, this.color, this.label);

  final int value;
  final String emoji;
  final Color color;
  final String label;
}
