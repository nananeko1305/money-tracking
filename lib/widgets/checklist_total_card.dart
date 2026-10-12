import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/money_currency.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The box atop a checklist: the money planned for every item, and for the
/// ones not ticked off yet.
class ChecklistTotalCard extends StatelessWidget {
  final double total;
  final double left;
  final MoneyCurrency currency;

  const ChecklistTotalCard({
    super.key,
    required this.total,
    required this.left,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.subtleFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        children: [
          AmountRow(t.checklistTotal, t.money(total, currency), emphasized: true),
          const SizedBox(height: 8),
          AmountRow(t.remaining, t.money(left, currency), color: pal.spent),
        ],
      ),
    );
  }
}
