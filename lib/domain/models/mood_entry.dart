/// Domain entity representing one mood journal entry.
///
/// This model is storage-agnostic and used across presentation/domain/data
/// layers.
class MoodEntry {
  /// Creates a mood entry.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the entry.
  /// - [mood]: Numeric mood value used by chart/statistics logic.
  /// - [notes]: Optional user note (can be empty string).
  /// - [timestamp]: Date/time when the mood was recorded.
  /// - [emoji]: Emoji representation matching the selected mood.
  /// - [intensity]: Optional extra numeric intensity metadata.
  const MoodEntry({
    required this.id,
    required this.mood,
    required this.notes,
    required this.timestamp,
    required this.emoji,
    this.intensity,
  });

  final String id;
  final int mood;
  final String notes;
  final DateTime timestamp;
  final String emoji;
  final int? intensity;
}
