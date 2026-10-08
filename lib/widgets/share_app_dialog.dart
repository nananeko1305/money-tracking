import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../services/release_links.dart';
import 'qr_code_view.dart';

/// "Share the app": a QR code another phone scans to download the newest
/// APK, the link itself, and a button to copy it.
Future<void> showShareAppDialog(BuildContext context) {
  final t = AppScope.of(context).strings;
  final hint = TextStyle(fontSize: 13, color: Theme.of(context).hintColor);

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.shareApp),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.shareAppMsg, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const QrCodeView(data: ReleaseLinks.latestApk),
            const SizedBox(height: 12),
            SelectableText(
              ReleaseLinks.latestApk,
              textAlign: TextAlign.center,
              style: hint,
            ),
            const SizedBox(height: 8),
            Text(t.shareAccountHint, textAlign: TextAlign.center, style: hint),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await Clipboard.setData(
                const ClipboardData(text: ReleaseLinks.latestApk));
            messenger.showSnackBar(SnackBar(content: Text(t.linkCopied)));
          },
          child: Text(t.copyLink),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t.close),
        ),
      ],
    ),
  );
}
