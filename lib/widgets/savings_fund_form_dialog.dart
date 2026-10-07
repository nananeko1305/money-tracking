import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/savings_fund.dart';

/// The values entered in the savings fund add / edit form.
class SavingsFundFormResult {
  final String name;
  final double openingBalance;
  final double target;
  const SavingsFundFormResult(this.name, this.openingBalance, this.target);
}

/// Shows the add / edit savings fund dialog. Returns the entered values, or
/// null if it was dismissed. Pass [existing] to prefill the fields for editing.
/// The opening balance and goal are optional; left empty they are 0.
Future<SavingsFundFormResult?> showSavingsFundFormDialog(
  BuildContext context, {
  SavingsFund? existing,
}) {
  final t = AppScope.of(context).strings;
  String prefill(double? v) => v != null && v > 0 ? amountInputText(v) : '';
  final nameController = TextEditingController(text: existing?.name ?? '');
  final openingController =
      TextEditingController(text: prefill(existing?.openingBalance));
  final targetController =
      TextEditingController(text: prefill(existing?.target));

  double? optionalAmount(TextEditingController c) =>
      c.text.trim().isEmpty ? 0 : parseAmountInput(c.text);

  return showDialog<SavingsFundFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newSavings : t.editSavings),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: t.name,
                hintText: t.savingsNameHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: openingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: t.openingBalanceLabel,
                helperText: t.openingBalanceHelp,
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
              ),
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
            final opening = optionalAmount(openingController);
            final target = optionalAmount(targetController);
            if (name.isEmpty ||
                opening == null ||
                opening < 0 ||
                target == null ||
                target < 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(t.invalidSavings)),
              );
              return;
            }
            Navigator.pop(ctx, SavingsFundFormResult(name, opening, target));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
