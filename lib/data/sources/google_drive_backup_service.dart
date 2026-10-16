import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/models/mood_entry.dart';
import '../models/mood_entry_model.dart';

class GoogleDriveBackupService {
  static const _scope = 'https://www.googleapis.com/auth/drive.appdata';
  static const _fileName = 'lumina_mood_backup.json';
  static final _filesUri = Uri.parse('https://www.googleapis.com/drive/v3/files');
  static final _uploadUri = Uri.parse(
    'https://www.googleapis.com/upload/drive/v3/files',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? _account;
  Future<void>? _initialization;

  Future<GoogleDriveConnection> connect() async {
    await _initialize();
    final account = _account ??= await _googleSignIn.authenticate();
    final authorization = await account.authorizationClient.authorizeScopes([
      _scope,
    ]);

    return GoogleDriveConnection(
      email: account.email,
      accessToken: authorization.accessToken,
    );
  }

  void clearAccount() {
    _account = null;
  }

  Future<GoogleDriveBackupResult> backup(
    List<MoodEntry> entries, {
    String? fileId,
  }) async {
    final connection = await connect();
    final content = MoodBackupDocument.fromEntries(entries).toJson();
    var resolvedFileId = fileId ?? await _findFileId(connection.accessToken);

    resolvedFileId ??= await _createFile(connection.accessToken);

    try {
      await _uploadContent(
        connection.accessToken,
        resolvedFileId,
        content,
      );
    } on GoogleDriveException catch (error) {
      if (error.statusCode != HttpStatus.notFound) {
        rethrow;
      }

      resolvedFileId = await _createFile(connection.accessToken);
      await _uploadContent(connection.accessToken, resolvedFileId, content);
    }

    return GoogleDriveBackupResult(
      email: connection.email,
      fileId: resolvedFileId,
      completedAt: DateTime.now(),
    );
  }

  Future<GoogleDriveRestoreResult> restore({String? fileId}) async {
    final connection = await connect();
    var resolvedFileId = fileId ?? await _findFileId(connection.accessToken);

    if (resolvedFileId == null) {
      throw const GoogleDriveException('Backup file was not found.');
    }

    String content;
    try {
      content = await _downloadContent(connection.accessToken, resolvedFileId);
    } on GoogleDriveException catch (error) {
      if (error.statusCode != HttpStatus.notFound || fileId == null) {
        rethrow;
      }
      resolvedFileId = await _findFileId(connection.accessToken);
      if (resolvedFileId == null) {
        throw const GoogleDriveException('Backup file was not found.');
      }
      content = await _downloadContent(connection.accessToken, resolvedFileId);
    }

    return GoogleDriveRestoreResult(
      email: connection.email,
      fileId: resolvedFileId,
      document: MoodBackupDocument.fromJson(content),
    );
  }

  Future<void> _initialize() {
    _initialization ??= _googleSignIn.initialize();
    return _initialization!;
  }

  Future<String?> _findFileId(String accessToken) async {
    final response = await _request(
      'GET',
      _filesUri.replace(
        queryParameters: {
          'q': "'appDataFolder' in parents and name = '$_fileName' and trashed = false",
          'spaces': 'appDataFolder',
          'fields': 'files(id,name)',
        },
      ),
      accessToken,
    );
    final decoded = jsonDecode(response);
    if (decoded is! Map || decoded['files'] is! List) {
      throw const FormatException('Invalid Google Drive file response.');
    }

    final files = decoded['files'] as List;
    if (files.isEmpty || files.first is! Map) {
      return null;
    }

    return (files.first as Map)['id'] as String?;
  }

  Future<String> _createFile(String accessToken) async {
    final response = await _request(
      'POST',
      _filesUri,
      accessToken,
      body: jsonEncode({
        'name': _fileName,
        'parents': ['appDataFolder'],
        'mimeType': 'application/json',
      }),
      contentType: ContentType.json,
    );
    final decoded = jsonDecode(response);
    final fileId = decoded is Map ? decoded['id'] as String? : null;
    if (fileId == null || fileId.isEmpty) {
      throw const FormatException('Google Drive did not return a file ID.');
    }
    return fileId;
  }

  Future<void> _uploadContent(
    String accessToken,
    String fileId,
    String content,
  ) async {
    await _request(
      'PATCH',
      Uri.parse(
        '${_uploadUri.toString()}/$fileId?uploadType=media',
      ),
      accessToken,
      body: content,
      contentType: ContentType.json,
    );
  }

  Future<String> _downloadContent(String accessToken, String fileId) {
    return _request(
      'GET',
      Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
      ),
      accessToken,
    );
  }

  Future<String> _request(
    String method,
    Uri uri,
    String accessToken, {
    String? body,
    ContentType? contentType,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.openUrl(method, uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      if (contentType != null) {
        request.headers.contentType = contentType;
      }
      if (body != null) {
        request.write(body);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == HttpStatus.unauthorized) {
          await _account?.authorizationClient.clearAuthorizationToken(
            accessToken: accessToken,
          );
          _account = null;
        }
        throw GoogleDriveException(
          'Google Drive request failed (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
      return responseBody;
    } finally {
      client.close(force: true);
    }
  }
}

class GoogleDriveConnection {
  const GoogleDriveConnection({required this.email, required this.accessToken});

  final String email;
  final String accessToken;
}

class GoogleDriveBackupResult {
  const GoogleDriveBackupResult({
    required this.email,
    required this.fileId,
    required this.completedAt,
  });

  final String email;
  final String fileId;
  final DateTime completedAt;
}

class GoogleDriveRestoreResult {
  const GoogleDriveRestoreResult({
    required this.email,
    required this.fileId,
    required this.document,
  });

  final String email;
  final String fileId;
  final MoodBackupDocument document;
}

class MoodBackupDocument {
  const MoodBackupDocument({
    required this.schemaVersion,
    required this.exportedAt,
    required this.entries,
  });

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime exportedAt;
  final List<MoodEntry> entries;

  factory MoodBackupDocument.fromEntries(List<MoodEntry> entries) {
    return MoodBackupDocument(
      schemaVersion: currentSchemaVersion,
      exportedAt: DateTime.now().toUtc(),
      entries: List.unmodifiable(entries),
    );
  }

  factory MoodBackupDocument.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Backup must contain a JSON object.');
    }
    if (decoded['schemaVersion'] != currentSchemaVersion) {
      throw const FormatException('Unsupported backup schema version.');
    }

    final exportedAtValue = decoded['exportedAt'];
    final exportedAt = exportedAtValue is String
        ? DateTime.tryParse(exportedAtValue)
        : null;
    final rawEntries = decoded['entries'];
    if (exportedAt == null || rawEntries is! List) {
      throw const FormatException('Backup is missing required fields.');
    }

    final entries = rawEntries.map((rawEntry) {
      if (rawEntry is! Map) {
        throw const FormatException('Backup contains an invalid mood entry.');
      }
      return MoodEntryModel.fromMap(rawEntry);
    }).toList();

    return MoodBackupDocument(
      schemaVersion: currentSchemaVersion,
      exportedAt: exportedAt,
      entries: List.unmodifiable(entries),
    );
  }

  String toJson() {
    return jsonEncode({
      'schemaVersion': schemaVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'entries': entries.map((entry) => MoodEntryModel.fromEntry(entry).toMap()).toList(),
    });
  }
}

class GoogleDriveException implements Exception {
  const GoogleDriveException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
