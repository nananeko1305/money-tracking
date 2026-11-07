import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/money_currency.dart';
import '../theme.dart';
import 'amount_row.dart';
import 'spending_bar.dart';

/// The "this week: spent of limit" line of a category card, with its own
/// thinner bar under it. Shown only for a category with a weekly limit.
class CategoryWeekRow extends StatelessWidget {
  final double spent;
  final double limit;
  final MoneyCurrency currency;
  final Color color;

  const CategoryWeekRow({
    super.key,
    required this.spent,
    required this.limit,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AmountRow(
          t.thisWeek,
          t.weekOf(t.amount(spent), t.money(limit, currency)),
          color: spent > limit ? pal.danger : null,
        ),
        const SizedBox(height: 6),
        SpendingBar(spent: spent, limit: limit, color: color, height: 6),
      ],
    );
  }
}
