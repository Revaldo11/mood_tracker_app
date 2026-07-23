class MoodEntry {
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
