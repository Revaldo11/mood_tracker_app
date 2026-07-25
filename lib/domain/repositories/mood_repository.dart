import '../models/mood_entry.dart';

/// Abstraction for mood persistence.
///
/// Implementations may store data in local database, remote API, or both.
abstract class MoodRepository {
  /// Loads all mood entries.
  ///
  /// Returns entries sorted according to implementation rules.
  ///
  /// Throws:
  /// - Underlying storage exceptions from the concrete implementation.
  Future<List<MoodEntry>> getEntries();

  /// Persists a mood [entry].
  ///
  /// Side effects:
  /// - Writes data to underlying storage.
  ///
  /// Throws:
  /// - Underlying storage exceptions from the concrete implementation.
  Future<void> saveEntry(MoodEntry entry);
}
