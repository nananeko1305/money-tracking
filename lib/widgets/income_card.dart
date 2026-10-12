import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/income_totals.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The dashboard card for the month's income (salary): how much of it is
/// allocated to categories, paid in fixed costs or moved to savings, and how
/// much is left after spending, one block per currency with an income. With no income set it
/// invites the user to enter one.
class IncomeCard extends StatelessWidget {
  final List<IncomeTotals> totals;
  final VoidCallback onEdit;

  const IncomeCard({super.key, required this.totals, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final pal = palette(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: totals.isEmpty
          ? _prompt(context, pal)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, pal),
                for (final (i, block) in totals.indexed) ...[
                  if (i > 0) const Divider(height: 32, thickness: 1.5),
                  _summary(context, pal, block),
                ],
              ],
            ),
    );
  }

  Widget _header(BuildContext context, AppPalette pal) {
    final t = AppScope.of(context).strings;
    return Row(
      children: [
        Icon(Icons.payments, color: pal.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            t.monthlyIncome,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        if (totals.isNotEmpty)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
          ),
      ],
    );
  }

  Widget _prompt(BuildContext context, AppPalette pal) {
    final t = AppScope.of(context).strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, pal),
        const SizedBox(height: 8),
        Text(
          t.incomeEmptyMsg,
          style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: pal.green),
          onPressed: onEdit,
          icon: const Icon(Icons.add),
          label: Text(t.setIncome),
        ),
      ],
    );
  }

  Widget _summary(BuildContext context, AppPalette pal, IncomeTotals x) {
    final t = AppScope.of(context).strings;
    final unallocated = x.unallocated;
    final left = x.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.money(x.income, x.currency),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: pal.green,
          ),
        ),
        const SizedBox(height: 12),
        AmountRow(t.allocated, t.money(x.allocated, x.currency)),
        if (x.fixed != 0) ...[
          const SizedBox(height: 6),
          AmountRow(t.fixedCostsRow, t.money(x.fixed, x.currency)),
        ],
        if (x.saved != 0) ...[
          const SizedBox(height: 6),
          AmountRow(t.savingsThisMonth, t.signedMoney(x.saved, x.currency)),
        ],
        const SizedBox(height: 6),
        AmountRow(
          t.unallocated,
          t.money(unallocated, x.currency),
          color: unallocated < 0 ? pal.danger : pal.positive,
        ),
        const Divider(height: 24),
        AmountRow(
          t.leftOfIncome,
          t.money(left, x.currency),
          color: left < 0 ? pal.danger : pal.positive,
          emphasized: true,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: x.usedShare,
            minHeight: 8,
            backgroundColor: pal.subtleFill,
            valueColor: AlwaysStoppedAnimation(left < 0 ? pal.danger : pal.green),
          ),
        ),
      ],
    );
  }
}
