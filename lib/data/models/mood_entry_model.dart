import '../../domain/models/mood_entry.dart';

/// Data-layer model for serializing/deserializing mood entries.
///
/// Extends [MoodEntry] and adds mapper helpers for local storage.
class MoodEntryModel extends MoodEntry {
  /// Creates a serializable mood entry model.
  const MoodEntryModel({
    required super.id,
    required super.mood,
    required super.notes,
    required super.timestamp,
    required super.emoji,
    super.intensity,
  });

  /// Builds a model from untyped map data read from local storage.
  ///
  /// Parameters:
  /// - [map]: Serialized mood payload.
  ///
  /// Returns a parsed [MoodEntryModel].
  ///
  /// Throws:
  /// - [TypeError] or [FormatException] if map values are invalid.
  factory MoodEntryModel.fromMap(Map<dynamic, dynamic> map) {
    return MoodEntryModel(
      id: map['id'] as String,
      mood: map['mood'] as int,
      notes: map['notes'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      emoji: map['emoji'] as String,
      intensity: map['intensity'] as int?,
    );
  }

  /// Converts a domain [entry] to data-layer model.
  factory MoodEntryModel.fromEntry(MoodEntry entry) {
    return MoodEntryModel(
      id: entry.id,
      mood: entry.mood,
      notes: entry.notes,
      timestamp: entry.timestamp,
      emoji: entry.emoji,
      intensity: entry.intensity,
    );
  }

  /// Serializes this model into a map for storage.
  ///
  /// Returns key/value payload accepted by Hive box storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'emoji': emoji,
      'intensity': intensity,
    };
  }
}
