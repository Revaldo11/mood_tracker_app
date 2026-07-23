import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mood_tracker/domain/models/mood_entry.dart';
import 'package:mood_tracker/domain/repositories/mood_repository.dart';
import 'package:mood_tracker/presentation/controllers/mood_controller.dart';

void main() {
  test('MoodController saves mood entries', () async {
    Get.testMode = true;
    final repository = _FakeMoodRepository();
    final controller = MoodController(repository);

    controller.selectMood(controller.moods.last);
    controller.notesController.text = 'Feeling focused';
    await controller.saveMood();

    expect(repository.savedEntries, hasLength(1));
    expect(repository.savedEntries.first.mood, 5);
    expect(repository.savedEntries.first.emoji, '😊');
    expect(repository.savedEntries.first.notes, 'Feeling focused');

    controller.onClose();
    Get.reset();
  });
}

class _FakeMoodRepository implements MoodRepository {
  final savedEntries = <MoodEntry>[];

  @override
  Future<List<MoodEntry>> getEntries() async {
    return savedEntries;
  }

  @override
  Future<void> saveEntry(MoodEntry entry) async {
    savedEntries.add(entry);
  }
}
