import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/category.dart';
import '../models/money_currency.dart';
import 'currency_selector.dart';

/// The values entered in the category add / edit form.
class CategoryFormResult {
  final String name;
  final double budget;
  final MoneyCurrency currency;
  const CategoryFormResult(this.name, this.budget, this.currency);
}

/// Shows the add / edit category dialog. Returns the entered values, or null if
/// the dialog was dismissed. Pass [existing] to prefill the fields for editing.
Future<CategoryFormResult?> showCategoryFormDialog(
  BuildContext context, {
  Category? existing,
}) {
  final t = AppScope.of(context).strings;
  final nameController = TextEditingController(text: existing?.name ?? '');
  final budgetController = TextEditingController(
      text: existing != null ? amountInputText(existing.budget) : '');
  var currency = existing?.currency ?? MoneyCurrency.rsd;

  return showDialog<CategoryFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newCategory : t.editCategory),
      // One builder for the whole form: the budget's currency suffix follows
      // the currency selector.
      content: StatefulBuilder(
        builder: (_, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: t.name,
                hintText: t.nameHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: t.budget.replaceAll(':', ''),
                hintText: t.budgetHint,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = nameController.text.trim();
            final budget = parseAmountInput(budgetController.text);
            if (name.isEmpty || budget == null || budget <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(t.invalidCategory),
              ));
              return;
            }
            Navigator.pop(ctx, CategoryFormResult(name, budget, currency));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
