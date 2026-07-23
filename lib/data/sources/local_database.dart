import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../models/mood_entry_model.dart';

class LocalDatabase implements MoodRepository {
  LocalDatabase(this._box);

  static const boxName = 'mood_entries';

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
}
