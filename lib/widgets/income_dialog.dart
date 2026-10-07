import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';

/// Shows the monthly income dialog, prefilled with [current] when it is set.
/// Returns the entered income (0 clears it), or null if it was dismissed.
Future<double?> showIncomeDialog(BuildContext context, {double current = 0}) {
  final t = AppScope.of(context).strings;
  final controller = TextEditingController(
      text: current > 0 ? amountInputText(current) : '');

  return showDialog<double>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.monthlyIncome),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: t.incomeHint,
          helperText: t.incomeHelp,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            final text = controller.text.trim();
            final income = text.isEmpty ? 0.0 : parseAmountInput(text);
            if (income == null || income < 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(t.invalidAmount)),
              );
              return;
            }
            Navigator.pop(ctx, income);
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
