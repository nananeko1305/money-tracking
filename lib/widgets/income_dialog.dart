import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/money_currency.dart';

/// Asks for the monthly income in dinars and in euros, both optional (empty
/// means 0, which clears it). Returns null if the dialog was dismissed.
/// [current] prefills the fields.
Future<Map<MoneyCurrency, double>?> showIncomeDialog(
  BuildContext context, {
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
      title: Text(t.monthlyIncome),
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
                hintText: c == MoneyCurrency.rsd ? t.incomeHint : null,
                helperText: i == 0 ? t.incomeHelp : null,
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
            final incomes = <MoneyCurrency, double>{};
            for (final MapEntry(key: c, value: controller)
                in controllers.entries) {
              final text = controller.text.trim();
              final income = text.isEmpty ? 0.0 : parseAmountInput(text);
              if (income == null || income < 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(t.invalidAmount)),
                );
                return;
              }
              incomes[c] = income;
            }
            Navigator.pop(ctx, incomes);
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
