import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';

/// The dashboard summary card: total budget, spent and remaining.
class TotalsCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;

  const TotalsCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
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
          _row(t.totalBudget, t.din(totalBudget), null),
          const SizedBox(height: 8),
          _row(t.totalSpent, t.din(totalSpent), pal.spent),
          const SizedBox(height: 8),
          _row(
            t.remaining,
            t.din(totalRemaining),
            totalRemaining < 0 ? pal.danger : pal.positive,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color? color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
