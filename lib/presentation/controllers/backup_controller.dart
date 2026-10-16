import 'package:get/get.dart';

import '../../data/sources/google_drive_backup_service.dart';
import '../../data/sources/local_database.dart';
import 'mood_controller.dart';

class BackupController extends GetxController {
  BackupController(this._database, this._service, this._moodController);

  final LocalDatabase _database;
  final GoogleDriveBackupService _service;
  final MoodController _moodController;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final connectedEmail = RxnString();
  final lastBackupAt = Rxn<DateTime>();
  String? _metadataUserId;

  @override
  void onInit() {
    super.onInit();
    _loadMetadata();
  }

  bool get isConnected => connectedEmail.value != null;

  void refreshForCurrentUser() {
    final userId = _database.currentUser?.id;
    if (_metadataUserId != userId) {
      _service.clearAccount();
      _metadataUserId = userId;
    }
    _setMetadataFromDatabase();
  }

  Future<bool> connect() async {
    return _run(() async {
      refreshForCurrentUser();
      final connection = await _service.connect();
      if (_database.driveEmail != null &&
          _database.driveEmail != connection.email) {
        await _database.clearDriveFileId();
      }
      await _database.saveDriveMetadata(email: connection.email);
      _setMetadataFromDatabase();
    });
  }

  Future<bool> backup() async {
    return _run(() async {
      refreshForCurrentUser();
      final result = await _service.backup(
        await _database.getEntries(),
        fileId: _database.driveFileId,
      );
      await _database.saveDriveMetadata(
        email: result.email,
        fileId: result.fileId,
        lastBackupAt: result.completedAt,
      );
      _setMetadataFromDatabase();
    });
  }

  Future<bool> restore() async {
    return _run(() async {
      refreshForCurrentUser();
      final result = await _service.restore(fileId: _database.driveFileId);
      for (final entry in result.document.entries) {
        await _database.saveEntry(entry);
      }
      await _database.saveDriveMetadata(
        email: result.email,
        fileId: result.fileId,
      );
      _setMetadataFromDatabase();
      await _moodController.loadEntries();
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (isLoading.value) {
      return false;
    }

    if (_database.currentUser == null) {
      errorMessage.value = 'An active user is required.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      await action();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMetadata() {
    refreshForCurrentUser();
  }

  void _setMetadataFromDatabase() {
    connectedEmail.value = _database.driveEmail;
    lastBackupAt.value = _database.driveLastBackupAt;
  }
}
