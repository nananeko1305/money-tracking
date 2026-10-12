import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/money_currency.dart';
import '../models/savings_fund.dart';
import 'currency_selector.dart';

/// The values entered in the savings fund add / edit form.
class SavingsFundFormResult {
  final String name;
  final Map<MoneyCurrency, double> openingBalances;
  final double target;
  final MoneyCurrency currency; // the goal's
  const SavingsFundFormResult(
      this.name, this.openingBalances, this.target, this.currency);
}

/// Shows the add / edit savings fund dialog. Returns the entered values, or
/// null if it was dismissed. Pass [existing] to prefill the fields for editing.
/// A fund can already hold dinars and euros, so there is an opening balance
/// for each; the goal is in one currency, picked under it. All are optional;
/// left empty they are 0.
Future<SavingsFundFormResult?> showSavingsFundFormDialog(
  BuildContext context, {
  SavingsFund? existing,
}) {
  final t = AppScope.of(context).strings;
  String prefill(double? v) => v != null && v > 0 ? amountInputText(v) : '';
  final nameController = TextEditingController(text: existing?.name ?? '');
  final openingControllers = {
    for (final c in MoneyCurrency.values)
      c: TextEditingController(text: prefill(existing?.openingIn(c))),
  };
  final targetController =
      TextEditingController(text: prefill(existing?.target));

  double? optionalAmount(TextEditingController c) =>
      c.text.trim().isEmpty ? 0 : parseAmountInput(c.text);
  var currency = existing?.currency ?? MoneyCurrency.rsd;

  return showDialog<SavingsFundFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newSavings : t.editSavings),
      content: SingleChildScrollView(
        // One builder for the whole form: the goal's currency suffix follows
        // the currency selector under it.
        child: StatefulBuilder(
          builder: (_, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: t.name,
                  hintText: t.savingsNameHint,
                ),
              ),
              const SizedBox(height: 16),
              Text(t.openingBalanceLabel,
                  style: TextStyle(color: Theme.of(context).hintColor)),
              for (final (i, c) in MoneyCurrency.values.indexed)
                TextField(
                  controller: openingControllers[c],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: c == MoneyCurrency.rsd ? t.dinars : t.euros,
                    helperText: i == MoneyCurrency.values.length - 1
                        ? t.openingBalanceHelp
                        : null,
                    suffixText: t.currencySymbol(c),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: t.savingsGoalLabel,
                  hintText: t.savingsGoalHint,
                  suffixText: t.currencySymbol(currency),
                ),
              ),
              const SizedBox(height: 8),
              CurrencySelector(
                selected: currency,
                onChanged: (c) => setState(() => currency = c),
              ),
            ],
          ),
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
            final openings = {
              for (final MapEntry(key: c, value: controller)
                  in openingControllers.entries)
                c: optionalAmount(controller),
            };
            final target = optionalAmount(targetController);
            if (name.isEmpty ||
                openings.values.any((v) => v == null || v < 0) ||
                target == null ||
                target < 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(t.invalidSavings)),
              );
              return;
            }
            Navigator.pop(
                ctx,
                SavingsFundFormResult(
                    name,
                    {
                      for (final MapEntry(key: c, value: v)
                          in openings.entries)
                        if (v! > 0) c: v,
                    },
                    target,
                    currency));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
