import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/category.dart';

/// The values entered in the category add / edit form.
class CategoryFormResult {
  final String name;
  final double budget;
  const CategoryFormResult(this.name, this.budget);
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
      text: existing != null ? t.amount(existing.budget) : '');

  return showDialog<CategoryFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newCategory : t.editCategory),
      content: Column(
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
            final budget = double.tryParse(
                budgetController.text.trim().replaceAll(',', '.'));
            if (name.isEmpty || budget == null || budget <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(t.invalidCategory),
              ));
              return;
            }
            Navigator.pop(ctx, CategoryFormResult(name, budget));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
