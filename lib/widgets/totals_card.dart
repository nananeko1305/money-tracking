import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import '../models/budget_totals.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The dashboard summary card: total budget, spent and remaining, one block
/// per currency. Dinars and euros are never added together.
class TotalsCard extends StatelessWidget {
  final List<BudgetTotals> totals;

  const TotalsCard({super.key, required this.totals});

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
          for (final (i, block) in totals.indexed) ...[
            if (i > 0) const Divider(height: 32, thickness: 1.5),
            ..._block(t, pal, block),
          ],
        ],
      ),
    );
  }

  List<Widget> _block(AppStrings t, AppPalette pal, BudgetTotals x) => [
        AmountRow(t.totalBudget, t.money(x.budget, x.currency)),
        const SizedBox(height: 8),
        AmountRow(t.totalSpent, t.money(x.spent, x.currency),
            color: pal.spent),
        const SizedBox(height: 8),
        AmountRow(
          t.remaining,
          t.money(x.remaining, x.currency),
          color: x.remaining < 0 ? pal.danger : pal.positive,
        ),
      ];
}
