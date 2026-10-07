import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/savings_fund.dart';
import '../theme.dart';
import 'amount_row.dart';

/// A single savings fund: its balance, progress toward the goal (if any) and
/// buttons to deposit or withdraw. Tapping the header opens the history.
class SavingsFundCard extends StatelessWidget {
  final SavingsFund fund;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const SavingsFundCard({
    super.key,
    required this.fund,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final color = hexColor(fund.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, color, pal),
          const SizedBox(height: 8),
          AmountRow(t.savingsBalance, t.din(fund.balance),
              color: pal.positive, emphasized: true),
          if (fund.hasTarget) ..._goal(context, color, pal),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.remove),
                  label: Text(t.withdraw),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: pal.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onDeposit,
                  icon: const Icon(Icons.add),
                  label: Text(t.deposit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, Color color, AppPalette pal) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fund.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${fund.entries.length}',
            style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
          ),
          const Icon(Icons.chevron_right, size: 20),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, size: 20, color: pal.danger),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  List<Widget> _goal(BuildContext context, Color color, AppPalette pal) {
    final t = AppScope.of(context).strings;
    final percent = fund.percentOfTarget;
    return [
      const SizedBox(height: 4),
      AmountRow(t.savingsGoal, t.din(fund.target)),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (percent / 100).clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: pal.subtleFill,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        t.goalProgress(percent.toStringAsFixed(0)),
        style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
      ),
    ];
  }
}
