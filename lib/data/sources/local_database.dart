import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../models/mood_entry_model.dart';

/// Hive-backed local persistence implementation for mood tracking data.
///
/// Stores:
/// - Mood entries in the `mood_entries` box.
/// - Onboarding state keys in the same box.
///
/// Example:
/// ```dart
/// final db = await LocalDatabase.init();
/// await db.saveEntry(
///   MoodEntry(
///     id: '1',
///     mood: 4,
///     notes: 'Productive day',
///     timestamp: DateTime.now(),
///     emoji: '🙂',
///   ),
/// );
/// final entries = await db.getEntries();
/// ```
class LocalDatabase implements MoodRepository {
  /// Creates local database wrapper with opened Hive [Box].
  LocalDatabase(this._box);

  /// Hive box name used by this project.
  static const boxName = 'mood_entries';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _onboardingStartedAtKey = 'onboarding_started_at';
  static const _onboardingScreenKey = 'onboarding_screen';

  final Box _box;

  /// Initializes Hive and opens the app's local box.
  ///
  /// Returns a ready-to-use [LocalDatabase] instance.
  ///
  /// Side effects:
  /// - Initializes Hive runtime.
  /// - Opens/creates local box file on device storage.
  ///
  /// Throws:
  /// - Propagates Hive initialization/open errors.
  static Future<LocalDatabase> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(boxName);
    return LocalDatabase(box);
  }

  @override
  /// Reads all stored mood entries and sorts by newest timestamp first.
  ///
  /// Returns:
  /// - A descending list of [MoodEntry].
  ///
  /// Throws:
  /// - Parsing/storage exceptions if a stored payload is invalid.
  Future<List<MoodEntry>> getEntries() async {
    final entries = _box.values
        .whereType<Map>()
        .map(MoodEntryModel.fromMap)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return entries;
  }

  @override
  /// Persists a single mood [entry].
  ///
  /// Side effects:
  /// - Inserts or overwrites item in Hive box keyed by entry id.
  ///
  /// Throws:
  /// - Hive write exceptions.
  Future<void> saveEntry(MoodEntry entry) async {
    final model = MoodEntryModel.fromEntry(entry);
    await _box.put(entry.id, model.toMap());
  }

  @override
  Future<void> removeEntry(String id) async {
    await _box.delete(id);
  }

  /// Indicates whether onboarding has been marked complete.
  bool get isOnboardingCompleted {
    return _box.get(_onboardingCompletedKey, defaultValue: false) as bool;
  }

  /// Returns the persisted onboarding page index.
  int get onboardingScreen {
    return _box.get(_onboardingScreenKey, defaultValue: 0) as int;
  }

  /// Stores onboarding start timestamp only once.
  ///
  /// Side effects:
  /// - Writes ISO timestamp key if not already present.
  Future<void> startOnboarding() async {
    if (!_box.containsKey(_onboardingStartedAtKey)) {
      await _box.put(
        _onboardingStartedAtKey,
        DateTime.now().toIso8601String(),
      );
    }
  }

  /// Persists onboarding [screen] index for resume behavior.
  Future<void> saveOnboardingScreen(int screen) async {
    await _box.put(_onboardingScreenKey, screen);
  }

  /// Marks onboarding as completed.
  ///
  /// Side effects:
  /// - Writes completion flag in local storage.
  Future<void> completeOnboarding() async {
    await _box.put(_onboardingCompletedKey, true);
  }
}
