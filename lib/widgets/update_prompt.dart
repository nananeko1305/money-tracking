import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../services/update_checker.dart';
import 'confirm_dialog.dart';

/// Offers a newer release. The app is not on any store, so it checks GitHub
/// Releases and asks whether to download the new APK. Runs on app start and on
/// every release push, and never stacks a second dialog on an open one.
class UpdatePrompt {
  UpdatePrompt({UpdateChecker? checker})
      : _checker = checker ?? UpdateChecker();

  final UpdateChecker _checker;
  bool _busy = false;

  Future<void> offer(BuildContext context) async {
    if (_busy) return;
    _busy = true;
    try {
      final update = await _checker.checkForUpdate();
      if (update == null || !context.mounted) return;

      final strings = AppScope.of(context).strings;
      final confirmed = await showConfirmDialog(
        context,
        title: strings.updateAvailableTitle,
        message: strings.updateAvailableMsg(update.versionName),
        confirmLabel: strings.download,
        cancelLabel: strings.notNow,
      );
      if (!confirmed) return;

      await launchUrl(
        Uri.parse(update.downloadUrl),
        mode: LaunchMode.externalApplication,
      );
    } finally {
      _busy = false;
    }
  }
}
