import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/category.dart';
import '../models/weekly_spending.dart';
import '../theme.dart';

/// Warns that the expense just added in [category] went past the category's
/// weekly limit, the weekly budget, or both. It only warns: the expense is
/// already recorded. Shows nothing when both limits still hold.
void showWeeklyOverrunWarning(
  BuildContext context,
  Category category,
  WeeklyOverrun over,
) {
  final t = AppScope.of(context).strings;
  final c = category.currency;
  final lines = [
    if (over.category > 0)
      t.overCategoryLimit(category.name, t.money(over.category, c)),
    if (over.budget > 0) t.overWeeklyBudget(t.money(over.budget, c)),
  ];
  if (lines.isEmpty) return;

  // The light theme's red in both themes: white text reads well on it.
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: AppPalette.light.danger,
      duration: const Duration(seconds: 5),
      content: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              lines.join('\n'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ));
}
