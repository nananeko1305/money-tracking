import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The dashboard card for the month's income (salary): how much of it is
/// allocated to categories or moved to savings, and how much is left after
/// spending. With no income set it invites the user to enter one.
class IncomeCard extends StatelessWidget {
  final double income;
  final double allocated; // sum of category budgets
  final double spent; // sum of category spending
  final double savedThisMonth; // net moved into savings this month
  final VoidCallback onEdit;

  const IncomeCard({
    super.key,
    required this.income,
    required this.allocated,
    required this.spent,
    required this.savedThisMonth,
    required this.onEdit,
  });

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
      child: income > 0 ? _summary(context, pal) : _prompt(context, pal),
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
        if (income > 0)
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

  Widget _summary(BuildContext context, AppPalette pal) {
    final t = AppScope.of(context).strings;
    final unallocated = income - allocated - savedThisMonth;
    final left = income - spent - savedThisMonth;
    final usedShare = ((spent + savedThisMonth) / income).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, pal),
        Text(
          t.din(income),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: pal.green,
          ),
        ),
        const SizedBox(height: 12),
        AmountRow(t.allocated, t.din(allocated)),
        if (savedThisMonth != 0) ...[
          const SizedBox(height: 6),
          AmountRow(t.savingsThisMonth, t.signedDin(savedThisMonth)),
        ],
        const SizedBox(height: 6),
        AmountRow(
          t.unallocated,
          t.din(unallocated),
          color: unallocated < 0 ? pal.danger : pal.positive,
        ),
        const Divider(height: 24),
        AmountRow(
          t.leftOfIncome,
          t.din(left),
          color: left < 0 ? pal.danger : pal.positive,
          emphasized: true,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: usedShare,
            minHeight: 8,
            backgroundColor: pal.subtleFill,
            valueColor: AlwaysStoppedAnimation(left < 0 ? pal.danger : pal.green),
          ),
        ),
      ],
    );
  }
}
