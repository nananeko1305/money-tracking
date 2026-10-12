import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import '../models/savings_totals.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The savings overview: the balance across all funds and the net amount
/// moved into savings this month, one block per currency. Dinars and euros
/// are never added together; there is no exchange rate.
class SavingsSummaryCard extends StatelessWidget {
  final List<SavingsTotals> totals;

  const SavingsSummaryCard({super.key, required this.totals});

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
          for (final (i, block) in totals.indexed) ...[
            if (i > 0) const Divider(height: 32, thickness: 1.5),
            ..._block(t, pal, block),
          ],
        ],
      ),
    );
  }

  List<Widget> _block(AppStrings t, AppPalette pal, SavingsTotals x) => [
        Text(t.totalSaved, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          t.money(x.balance, x.currency),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: pal.green,
          ),
        ),
        const SizedBox(height: 8),
        AmountRow(
          t.savedThisMonth,
          t.signedMoney(x.thisMonth, x.currency),
          color: x.thisMonth < 0 ? pal.spent : pal.positive,
        ),
      ];
}
