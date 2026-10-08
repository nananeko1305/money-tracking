import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist.dart';

/// Shows the new / rename checklist dialog. Returns the entered name, or null
/// if the dialog was dismissed. Pass [existing] to rename it.
Future<String?> showChecklistNameDialog(
  BuildContext context, {
  Checklist? existing,
}) {
  final t = AppScope.of(context).strings;
  final nameController = TextEditingController(text: existing?.name ?? '');

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newChecklist : t.renameChecklist),
      content: TextField(
        controller: nameController,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: t.name,
          hintText: t.checklistNameHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(t.invalidChecklist)),
              );
              return;
            }
            Navigator.pop(ctx, name);
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
