import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist.dart';
import '../models/money_currency.dart';
import 'currency_selector.dart';

/// The values entered in the checklist new / edit form.
class ChecklistFormResult {
  final String name;
  final MoneyCurrency currency;
  const ChecklistFormResult(this.name, this.currency);
}

/// Shows the new / edit checklist dialog: the list's name and the currency of
/// its planned amounts. Returns null if the dialog was dismissed. Pass
/// [existing] to edit it.
Future<ChecklistFormResult?> showChecklistFormDialog(
  BuildContext context, {
  Checklist? existing,
}) {
  final t = AppScope.of(context).strings;
  final nameController = TextEditingController(text: existing?.name ?? '');
  var currency = existing?.currency ?? MoneyCurrency.rsd;

  return showDialog<ChecklistFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newChecklist : t.renameChecklist),
      content: StatefulBuilder(
        builder: (_, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.name,
                hintText: t.checklistNameHint,
              ),
            ),
            const SizedBox(height: 12),
            CurrencySelector(
              selected: currency,
              onChanged: (c) => setState(() => currency = c),
            ),
          ],
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
            Navigator.pop(ctx, ChecklistFormResult(name, currency));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
