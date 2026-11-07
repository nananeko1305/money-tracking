import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/money_currency.dart';

/// Asks for one amount in dinars and one in euros, both optional (empty
/// means 0, which clears it): the monthly income, the weekly budget.
/// Returns null if the dialog was dismissed. [current] prefills the fields;
/// [hint] and [help] go on the dinar field.
Future<Map<MoneyCurrency, double>?> showCurrencyAmountsDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required String help,
  Map<MoneyCurrency, double> current = const {},
}) {
  final t = AppScope.of(context).strings;
  final controllers = {
    for (final c in MoneyCurrency.values)
      c: TextEditingController(
          text: (current[c] ?? 0) > 0 ? amountInputText(current[c]!) : ''),
  };

  return showDialog<Map<MoneyCurrency, double>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, c) in MoneyCurrency.values.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            TextField(
              controller: controllers[c],
              autofocus: i == 0,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: c == MoneyCurrency.rsd ? t.dinars : t.euros,
                hintText: c == MoneyCurrency.rsd ? hint : null,
                helperText: i == 0 ? help : null,
                suffixText: t.currencySymbol(c),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            final amounts = <MoneyCurrency, double>{};
            for (final MapEntry(key: c, value: controller)
                in controllers.entries) {
              final text = controller.text.trim();
              final amount = text.isEmpty ? 0.0 : parseAmountInput(text);
              if (amount == null || amount < 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(t.invalidAmount)),
                );
                return;
              }
              amounts[c] = amount;
            }
            Navigator.pop(ctx, amounts);
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
