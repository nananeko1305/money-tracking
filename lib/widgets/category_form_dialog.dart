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

  /// 0 when the weekly limit was left empty.
  final double weeklyLimit;
  const CategoryFormResult(this.name, this.budget, this.currency,
      {this.weeklyLimit = 0});
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
  final weeklyController = TextEditingController(
      text: (existing?.weeklyLimit ?? 0) > 0
          ? amountInputText(existing!.weeklyLimit)
          : '');
  var currency = existing?.currency ?? MoneyCurrency.rsd;

  return showDialog<CategoryFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newCategory : t.editCategory),
      // One builder for the whole form: the amounts' currency suffix follows
      // the currency selector. It scrolls so the keyboard never squeezes it.
      content: StatefulBuilder(
        builder: (_, setState) => SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 12),
              TextField(
                controller: weeklyController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: t.weeklyLimit,
                  helperText: t.weeklyLimitHelp,
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
            final budget = parseAmountInput(budgetController.text);
            if (name.isEmpty || budget == null || budget <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(t.invalidCategory),
              ));
              return;
            }
            final weeklyText = weeklyController.text.trim();
            final weekly =
                weeklyText.isEmpty ? 0.0 : parseAmountInput(weeklyText);
            if (weekly == null || weekly < 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(t.invalidAmount),
              ));
              return;
            }
            Navigator.pop(ctx,
                CategoryFormResult(name, budget, currency, weeklyLimit: weekly));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
