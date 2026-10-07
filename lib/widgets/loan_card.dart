import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/loan.dart';
import '../models/loan_direction.dart';
import '../theme.dart';
import 'amount_row.dart';

/// A single loan: who it is with, how much was repaid and what is left, plus
/// a button to record a repayment. Tapping the header opens the history.
class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRepay;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onRepay,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final accent =
        loan.direction == LoanDirection.lent ? pal.positive : pal.danger;

    return Opacity(
      opacity: loan.isSettled ? 0.6 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: pal.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: pal.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, pal),
            if (loan.note.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                loan.note,
                style:
                    TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
              ),
            ],
            const SizedBox(height: 8),
            AmountRow(t.loanAmount, t.din(loan.amount)),
            const SizedBox(height: 4),
            AmountRow(t.loanRepaid, t.din(loan.repaid), color: pal.spent),
            const SizedBox(height: 4),
            AmountRow(
              t.remaining,
              loan.isSettled ? t.loanSettled : t.din(loan.remaining),
              color: accent,
              emphasized: true,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (loan.percentRepaid / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: pal.subtleFill,
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
            if (!loan.isSettled) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRepay,
                  icon: const Icon(Icons.undo),
                  label: Text(t.recordRepayment),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppPalette pal) {
    final t = AppScope.of(context).strings;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.person,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  t.date(loan.date),
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor),
                ),
              ],
            ),
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
}
