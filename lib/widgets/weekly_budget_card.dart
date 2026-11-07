import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/money_currency.dart';
import '../models/weekly_spending.dart';
import '../theme.dart';
import 'amount_row.dart';
import 'spending_bar.dart';

/// The dashboard card for the weekly budget: what all categories together
/// have spent since Monday against what may be spent in the week, one block
/// per currency with a weekly budget. With none set it invites the user to
/// enter one.
class WeeklyBudgetCard extends StatelessWidget {
  final Map<MoneyCurrency, double> budgets;
  final WeeklySpending spending;
  final VoidCallback onEdit;

  const WeeklyBudgetCard({
    super.key,
    required this.budgets,
    required this.spending,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final set = [
      for (final c in MoneyCurrency.values)
        if ((budgets[c] ?? 0) > 0) c,
    ];
    final hint = TextStyle(fontSize: 14, color: Theme.of(context).hintColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, color: pal.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.weeklyBudget,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (set.isNotEmpty)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (set.isEmpty) ...[
            Text(t.weeklyBudgetEmptyMsg, style: hint),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: pal.green),
              onPressed: onEdit,
              icon: const Icon(Icons.add),
              label: Text(t.setWeeklyBudget),
            ),
          ] else ...[
            for (final (i, c) in set.indexed) ...[
              if (i > 0) const Divider(height: 32, thickness: 1.5),
              _block(context, pal, c, budgets[c]!, spending.inCurrency(c)),
            ],
            const SizedBox(height: 12),
            Text(t.newWeekIn(spending.daysLeft), style: hint),
          ],
        ],
      ),
    );
  }

  Widget _block(BuildContext context, AppPalette pal, MoneyCurrency c,
      double budget, double spent) {
    final t = AppScope.of(context).strings;
    final left = budget - spent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.money(budget, c),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: pal.green,
          ),
        ),
        const SizedBox(height: 12),
        AmountRow(t.spentThisWeek, t.money(spent, c), color: pal.spent),
        const SizedBox(height: 6),
        AmountRow(
          t.leftThisWeek,
          t.money(left, c),
          color: left < 0 ? pal.danger : pal.positive,
          emphasized: true,
        ),
        const SizedBox(height: 10),
        SpendingBar(spent: spent, limit: budget, color: pal.green),
      ],
    );
  }
}
