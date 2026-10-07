import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../services/backup.dart';
import '../services/budget_repository.dart';
import '../services/storage_permission.dart';
import 'confirm_dialog.dart';

/// The drawer's export / import: the account's data saved to a JSON file on
/// the phone, and a backup file imported back over it.
class BackupActions {
  BackupActions({BackupService? backup, StoragePermission? permission})
      : _backup = backup ?? BackupService(),
        _permission = permission ?? StoragePermission();

  final BackupService _backup;
  final StoragePermission _permission;

  Future<void> exportData(BuildContext context, BudgetRepository storage) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppScope.of(context).strings;

    final granted = await _permission.ensureGranted();
    if (!granted) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.storagePermissionDenied)),
      );
      return;
    }

    final json = await storage.exportJson();
    final path = await _backup.saveToDevice(json);
    messenger.showSnackBar(SnackBar(
      content: Text(path != null ? strings.exportSaved : strings.exportFailed),
    ));
  }

  Future<void> importData(BuildContext context, BudgetRepository storage) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppScope.of(context).strings;

    final confirmed = await showConfirmDialog(
      context,
      title: strings.importConfirmTitle,
      message: strings.importConfirmMsg,
      confirmLabel: strings.import,
      cancelLabel: strings.cancel,
    );
    if (!confirmed) return;

    final raw = await _backup.pickBackupFile();
    if (raw == null) return;

    final ok = await storage.importJson(raw);
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? strings.importSuccess : strings.importInvalid),
    ));
  }
}
