import 'package:flutter/material.dart';

import '../app_scope.dart';

/// Shown while the account's data cannot be loaded at all, instead of a
/// spinner that would never stop; the live view keeps retrying behind it.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              strings.retrying,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
