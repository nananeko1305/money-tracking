import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/money_currency.dart';
import 'currency_selector.dart';

/// The values entered in the amount entry dialog.
class AmountEntry {
  final double amount;
  final String description;
  final MoneyCurrency? currency; // the one picked, when there was a choice
  const AmountEntry(this.amount, this.description, {this.currency});
}

/// Shows a dialog asking for a positive amount and an optional description,
/// used for savings deposits / withdrawals and loan repayments. Returns null
/// if it was dismissed. [amountSuffix] names a fixed currency next to the
/// field; pass [currency] instead to let the user pick one, starting there.
Future<AmountEntry?> showAmountEntryDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? amountSuffix,
  MoneyCurrency? currency,
}) {
  final t = AppScope.of(context).strings;
  final amountController = TextEditingController();
  final descController = TextEditingController();

  return showDialog<AmountEntry>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: StatefulBuilder(
        builder: (_, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: t.amountHint,
                suffixText: currency != null
                    ? t.currencySymbol(currency!)
                    : amountSuffix,
              ),
            ),
            if (currency != null) ...[
              const SizedBox(height: 8),
              CurrencySelector(
                selected: currency!,
                onChanged: (c) => setState(() => currency = c),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: t.descHint),
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
            final amount = parseAmountInput(amountController.text);
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(t.invalidAmount)),
              );
              return;
            }
            Navigator.pop(
              ctx,
              AmountEntry(amount, descController.text, currency: currency),
            );
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
