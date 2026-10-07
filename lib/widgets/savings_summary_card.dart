import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The savings overview: the balance across all funds and the net amount
/// moved into savings this month.
class SavingsSummaryCard extends StatelessWidget {
  final double total;
  final double thisMonth;

  const SavingsSummaryCard({
    super.key,
    required this.total,
    required this.thisMonth,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.subtleFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.totalSaved, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            t.din(total),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: pal.green,
            ),
          ),
          const SizedBox(height: 8),
          AmountRow(
            t.savedThisMonth,
            t.signedDin(thisMonth),
            color: thisMonth < 0 ? pal.spent : pal.positive,
          ),
        ],
      ),
    );
  }
}
