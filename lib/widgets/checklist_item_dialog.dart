import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/checklist_item.dart';
import '../models/money_currency.dart';

/// The values entered in the checklist item add / edit form.
class ChecklistItemFormResult {
  final String name;
  final double amount; // 0 when left empty
  const ChecklistItemFormResult(this.name, this.amount);
}

/// Shows the add / edit item dialog. The amount is optional: some things go
/// on a list before their price is known. The amount is in the list's
/// [currency]. Returns null if dismissed. Pass [existing] to prefill the
/// fields for editing.
Future<ChecklistItemFormResult?> showChecklistItemDialog(
  BuildContext context, {
  required MoneyCurrency currency,
  ChecklistItem? existing,
}) {
  final t = AppScope.of(context).strings;
  final nameController = TextEditingController(text: existing?.name ?? '');
  final amountController = TextEditingController(
      text: existing != null && existing.amount > 0
          ? amountInputText(existing.amount)
          : '');

  return showDialog<ChecklistItemFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newItem : t.editItem),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: t.name,
              hintText: t.itemNameHint,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.itemAmountLabel,
              suffixText: t.currencySymbol(currency),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = nameController.text.trim();
            final rawAmount = amountController.text.trim();
            final amount =
                rawAmount.isEmpty ? 0.0 : parseAmountInput(rawAmount);
            if (name.isEmpty || amount == null || amount < 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(t.invalidItem)),
              );
              return;
            }
            Navigator.pop(ctx, ChecklistItemFormResult(name, amount));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
