import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../services/legacy_local_data.dart';
import '../services/user_session.dart';
import 'confirm_dialog.dart';

/// Offers to move the data this phone kept before accounts existed to the
/// signed-in account. Meant for an account that is still empty; until the
/// user agrees it is offered again on every start.
class LocalDataPrompt {
  LocalDataPrompt({LegacyLocalData? local})
      : _local = local ?? LegacyLocalData();

  final LegacyLocalData _local;

  /// Returns true when the data was moved.
  Future<bool> offer(BuildContext context, UserSession session) async {
    final data = await _local.pending();
    if (data == null || !context.mounted) return false;

    final strings = AppScope.of(context).strings;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: strings.moveDataTitle,
      message: strings.moveDataMsg,
      confirmLabel: strings.moveData,
      cancelLabel: strings.notNow,
    );
    if (!confirmed) return false;

    await session.live.ready();
    session.replacer.replaceWith(data);
    await _local.markMoved(session.uid);
    messenger.showSnackBar(SnackBar(content: Text(strings.moveDataDone)));
    return true;
  }
}
