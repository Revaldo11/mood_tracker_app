import '../models/mood_entry.dart';

abstract class MoodRepository {
  Future<List<MoodEntry>> getEntries();

  Future<void> saveEntry(MoodEntry entry);
}
