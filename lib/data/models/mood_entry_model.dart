import '../../domain/models/mood_entry.dart';

class MoodEntryModel extends MoodEntry {
  const MoodEntryModel({
    required super.id,
    required super.mood,
    required super.notes,
    required super.timestamp,
    required super.emoji,
    super.intensity,
  });

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
