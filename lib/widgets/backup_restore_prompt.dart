import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../services/backup.dart';
import '../services/budget_repository.dart';
import '../services/storage_permission.dart';
import 'confirm_dialog.dart';

/// Offers to find the newest backup file saved on the phone and import it.
/// Meant for an account that is still empty.
class BackupRestorePrompt {
  BackupRestorePrompt({BackupService? backup, StoragePermission? permission})
      : _backup = backup ?? BackupService(),
        _permission = permission ?? StoragePermission();

  final BackupService _backup;
  final StoragePermission _permission;

  Future<void> offer(BuildContext context, BudgetRepository storage) async {
    final strings = AppScope.of(context).strings;
    final messenger = ScaffoldMessenger.of(context);

    // Ask before requesting the system "All files access" permission, so a
    // brand-new user isn't surprised by it.
    final wantsCheck = await showConfirmDialog(
      context,
      title: strings.restorePromptTitle,
      message: strings.restorePromptMsg,
      confirmLabel: strings.check,
      cancelLabel: strings.notNow,
    );
    if (!wantsCheck) return;

    final granted = await _permission.ensureGranted();
    if (!context.mounted) return;
    if (!granted) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.storagePermissionDenied)),
      );
      return;
    }

    final backup = await _backup.findLatestBackup();
    if (!context.mounted) return;
    if (backup == null) {
      messenger.showSnackBar(SnackBar(content: Text(strings.noBackupsFound)));
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: strings.restoreFoundTitle,
      message: strings.restoreFoundMsg(backup.modified.toIso8601String()),
      confirmLabel: strings.import,
      cancelLabel: strings.cancel,
    );
    if (!confirmed) return;

    final raw = await _backup.readBackup(backup.path);
    final ok = raw != null && await storage.importJson(raw);
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? strings.importSuccess : strings.importInvalid),
    ));
  }
}
