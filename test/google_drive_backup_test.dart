import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker/data/sources/google_drive_backup_service.dart';
import 'package:mood_tracker/domain/models/mood_entry.dart';

void main() {
  final entry = MoodEntry(
    id: 'entry-1',
    mood: 5,
    notes: 'Feeling good',
    timestamp: DateTime(2026, 10, 15, 9),
    emoji: '😊',
  );

  test('backup document round-trips mood entries', () {
    final document = MoodBackupDocument.fromEntries([entry]);
    final restored = MoodBackupDocument.fromJson(document.toJson());

    expect(restored.schemaVersion, 1);
    expect(restored.entries, hasLength(1));
    expect(restored.entries.single.id, entry.id);
    expect(restored.entries.single.mood, entry.mood);
    expect(restored.entries.single.notes, entry.notes);
  });

  test('backup document rejects unsupported schema', () {
    expect(
      () => MoodBackupDocument.fromJson(
        '{"schemaVersion":2,"exportedAt":"2026-10-15T00:00:00Z","entries":[]}',
      ),
      throwsFormatException,
    );
  });

  test('backup document rejects malformed entries', () {
    expect(
      () => MoodBackupDocument.fromJson(
        '{"schemaVersion":1,"exportedAt":"2026-10-15T00:00:00Z","entries":[{}]}',
      ),
      throwsA(isA<TypeError>()),
    );
  });
}
