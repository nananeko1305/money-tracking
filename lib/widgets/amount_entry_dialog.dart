import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';

/// The values entered in the amount entry dialog.
class AmountEntry {
  final double amount;
  final String description;
  const AmountEntry(this.amount, this.description);
}

/// Shows a dialog asking for a positive amount and an optional description,
/// used for savings deposits / withdrawals and loan repayments. Returns null
/// if it was dismissed. [amountSuffix] names the currency next to the field.
Future<AmountEntry?> showAmountEntryDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? amountSuffix,
}) {
  final t = AppScope.of(context).strings;
  final amountController = TextEditingController();
  final descController = TextEditingController();

  return showDialog<AmountEntry>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.amountHint,
              suffixText: amountSuffix,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descController,
            decoration: InputDecoration(labelText: t.descHint),
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
            final amount = parseAmountInput(amountController.text);
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(t.invalidAmount)),
              );
              return;
            }
            Navigator.pop(ctx, AmountEntry(amount, descController.text));
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
