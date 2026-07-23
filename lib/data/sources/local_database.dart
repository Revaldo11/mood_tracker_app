import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../models/mood_entry_model.dart';

class LocalDatabase implements MoodRepository {
  LocalDatabase(this._box);

  static const boxName = 'mood_entries';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _onboardingStartedAtKey = 'onboarding_started_at';
  static const _onboardingScreenKey = 'onboarding_screen';

  final Box _box;

  static Future<LocalDatabase> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(boxName);
    return LocalDatabase(box);
  }

  @override
  Future<List<MoodEntry>> getEntries() async {
    final entries = _box.values
        .whereType<Map>()
        .map(MoodEntryModel.fromMap)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return entries;
  }

  @override
  Future<void> saveEntry(MoodEntry entry) async {
    final model = MoodEntryModel.fromEntry(entry);
    await _box.put(entry.id, model.toMap());
  }

  bool get isOnboardingCompleted {
    return _box.get(_onboardingCompletedKey, defaultValue: false) as bool;
  }

  int get onboardingScreen {
    return _box.get(_onboardingScreenKey, defaultValue: 0) as int;
  }

  Future<void> startOnboarding() async {
    if (!_box.containsKey(_onboardingStartedAtKey)) {
      await _box.put(
        _onboardingStartedAtKey,
        DateTime.now().toIso8601String(),
      );
    }
  }

  Future<void> saveOnboardingScreen(int screen) async {
    await _box.put(_onboardingScreenKey, screen);
  }

  Future<void> completeOnboarding() async {
    await _box.put(_onboardingCompletedKey, true);
  }
}
