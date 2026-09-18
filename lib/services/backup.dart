import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// A backup file discovered in the shared backups folder.
class BackupFile {
  final String path;
  final DateTime modified;
  const BackupFile({required this.path, required this.modified});
}

/// Saves and locates budget backups in a shared public folder
/// (Download/MoneyTracking) that survives app reinstalls, and supports manual
/// import via the system file picker. Requires storage access (see
/// StoragePermission) to reach the shared folder.
class BackupService {
  static const String folderName = 'MoneyTracking';
  static const String publicSubPath = 'Download/$folderName';
  static const String _filePrefix = 'money-tracking-backup-';

  /// Resolves (and creates) the shared backups directory. The shared-storage
  /// root is derived from the app-specific external dir so it works across
  /// devices, with a sensible fallback.
  Future<Directory> _backupsDir() async {
    final ext = await getExternalStorageDirectory();
    final root = ext != null && ext.path.contains('/Android/')
        ? ext.path.split('/Android/').first
        : '/storage/emulated/0';
    final dir = Directory('$root/$publicSubPath');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Writes [json] to a timestamped file in the shared folder. Returns the saved
  /// path, or null on failure.
  Future<String?> saveToDevice(String json) async {
    try {
      final dir = await _backupsDir();
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File('${dir.path}/$_filePrefix$stamp.json');
      await file.writeAsString(json);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Finds the most recently modified backup in the shared folder, or null.
  Future<BackupFile?> findLatestBackup() async {
    try {
      final dir = await _backupsDir();
      final backups = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.json'))
          .toList();
      if (backups.isEmpty) return null;
      backups.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));
      final latest = backups.first;
      return BackupFile(
        path: latest.path,
        modified: latest.statSync().modified,
      );
    } catch (_) {
      return null;
    }
  }

  /// Reads a backup file's contents, or null on failure.
  Future<String?> readBackup(String path) async {
    try {
      return await File(path).readAsString();
    } catch (_) {
      return null;
    }
  }

  /// Lets the user manually pick a JSON backup and returns its contents, or null
  /// if the picker was dismissed.
  Future<String?> pickBackupFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return null;

    final picked = files.single;
    final bytes = await picked.readAsBytes();
    return utf8.decode(bytes);
  }
}
