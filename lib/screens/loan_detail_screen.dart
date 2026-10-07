import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/loan.dart';
import '../models/loan_direction.dart';
import '../models/transaction.dart';
import '../services/loan_repository.dart';
import '../theme.dart';
import '../widgets/amount_row.dart';
import '../widgets/transaction_list.dart';

/// Shows the repayment history of one loan and allows deleting individual
/// repayments.
class LoanDetailScreen extends StatefulWidget {
  final LoanRepository storage;
  final String loanId;

  const LoanDetailScreen({
    super.key,
    required this.storage,
    required this.loanId,
  });

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  Loan? _loan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Follows every change, including the ones made on another phone.
    widget.storage.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.storage.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final loans = await widget.storage.loans();
    if (!mounted) return;
    setState(() {
      _loan = loans.where((l) => l.id == widget.loanId).firstOrNull;
      _loading = false;
    });
  }

  Future<void> _deleteRepayment(Transaction repayment) async {
    await widget.storage.deleteRepayment(widget.loanId, repayment.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final loan = _loan;

    return Scaffold(
      appBar: AppBar(title: Text(loan?.person ?? t.navLoans)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : loan == null
              ? Center(child: Text(t.loanNotFound))
              : _buildBody(context, loan),
    );
  }

  Widget _buildBody(BuildContext context, Loan loan) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final lent = loan.direction == LoanDirection.lent;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pal.subtleFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: pal.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${lent ? t.owedToMe : t.iOwe} · ${t.date(loan.date)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: lent ? pal.positive : pal.danger,
                ),
              ),
              if (loan.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(loan.note, style: const TextStyle(fontSize: 14)),
              ],
              const SizedBox(height: 10),
              AmountRow(t.loanAmount, t.din(loan.amount)),
              const SizedBox(height: 6),
              AmountRow(t.loanRepaid, t.din(loan.repaid), color: pal.spent),
              const SizedBox(height: 6),
              AmountRow(
                t.remaining,
                loan.isSettled ? t.loanSettled : t.din(loan.remaining),
                color: lent ? pal.positive : pal.danger,
                emphasized: true,
              ),
            ],
          ),
        ),
        Expanded(
          child: TransactionList(
            transactions: loan.repayments,
            emptyText: t.noRepayments,
            titleOf: (r) =>
                r.description.isNotEmpty ? r.description : t.repaymentEntry,
            amountOf: (r) => t.din(r.amount),
            colorOf: (_) => pal.positive,
            onDelete: _deleteRepayment,
          ),
        ),
      ],
    );
  }
}
