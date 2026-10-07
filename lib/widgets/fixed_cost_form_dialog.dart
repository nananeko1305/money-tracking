import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/fixed_cost.dart';

/// The values entered in the fixed cost add / edit form.
class FixedCostFormResult {
  final String name;
  final double amount;
  const FixedCostFormResult(this.name, this.amount);
}

/// Shows the add / edit fixed cost dialog. Returns the entered values, or null
/// if the dialog was dismissed. Pass [existing] to prefill the fields for
/// editing.
Future<FixedCostFormResult?> showFixedCostFormDialog(
  BuildContext context, {
  FixedCost? existing,
}) {
  final t = AppScope.of(context).strings;
  final nameController = TextEditingController(text: existing?.name ?? '');
  final amountController = TextEditingController(
      text: existing != null ? amountInputText(existing.amount) : '');

  return showDialog<FixedCostFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newFixedCost : t.editFixedCost),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.name,
              hintText: t.fixedCostNameHint,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.amountHint,
              hintText: t.fixedCostAmountHint,
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
            final amount = parseAmountInput(amountController.text);
            if (name.isEmpty || amount == null || amount <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(t.invalidFixedCost),
              ));
              return;
            }
            Navigator.pop(ctx, FixedCostFormResult(name, amount));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
