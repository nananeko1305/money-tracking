import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Handles exporting the budget backup to a shareable file and importing one
/// back from local storage.
class BackupService {
  /// Writes [json] to a timestamped file and opens the system share sheet.
  /// Returns false if sharing is not available on this platform.
  Future<bool> exportToFile(String json) async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File('${dir.path}/money-tracking-backup-$stamp.json');
    await file.writeAsString(json);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Money Tracking backup',
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Lets the user pick a JSON backup file and returns its contents, or null if
  /// the picker was dismissed.
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
