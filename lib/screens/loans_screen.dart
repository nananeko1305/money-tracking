import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/loan.dart';
import '../models/loan_direction.dart';
import '../services/loan_repository.dart';
import '../theme.dart';
import '../widgets/amount_entry_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/loan_card.dart';
import '../widgets/loan_form_dialog.dart';
import '../widgets/loan_summary_card.dart';
import 'loan_detail_screen.dart';

/// The "Loans" section: totals owed both ways, open loans grouped by
/// direction, and settled loans tucked away at the bottom.
class LoansScreen extends StatefulWidget {
  final LoanRepository storage;

  const LoansScreen({super.key, required this.storage});

  @override
  State<LoansScreen> createState() => LoansScreenState();
}

class LoansScreenState extends State<LoansScreen> {
  List<Loan> _loans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final loans = await widget.storage.loans();
    if (!mounted) return;
    setState(() {
      _loans = loans;
      _loading = false;
    });
  }

  List<Loan> _open(LoanDirection direction) => _loans
      .where((l) => l.direction == direction && !l.isSettled)
      .toList();

  double _owed(LoanDirection direction) =>
      _open(direction).fold(0.0, (s, l) => s + l.remaining);

  Future<void> _addLoan() async {
    final result = await showLoanFormDialog(context);
    if (result == null) return;
    await widget.storage.addLoan(
      person: result.person,
      direction: result.direction,
      amount: result.amount,
      note: result.note,
    );
    await reload();
  }

  Future<void> _editLoan(Loan loan) async {
    final result = await showLoanFormDialog(context, existing: loan);
    if (result == null) return;
    await widget.storage.updateLoan(
      loan.id,
      person: result.person,
      direction: result.direction,
      amount: result.amount,
      note: result.note,
    );
    await reload();
  }

  Future<void> _deleteLoan(Loan loan) async {
    final t = AppScope.of(context).strings;
    final confirmed = await showConfirmDialog(
      context,
      title: t.deleteLoanTitle,
      message: t.deleteLoanMsg(loan.person),
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await widget.storage.deleteLoan(loan.id);
    await reload();
  }

  Future<void> _repay(Loan loan) async {
    final t = AppScope.of(context).strings;
    final messenger = ScaffoldMessenger.of(context);
    final entry = await showAmountEntryDialog(context,
        title: t.repaymentTitle, confirmLabel: t.save);
    if (entry == null) return;
    if (entry.amount > loan.remaining + 0.005) {
      messenger.showSnackBar(SnackBar(content: Text(t.repaymentTooLarge)));
      return;
    }
    await widget.storage.addRepayment(loan.id, entry.amount, entry.description);
    await reload();
  }

  Future<void> _openDetail(Loan loan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LoanDetailScreen(storage: widget.storage, loanId: loan.id),
      ),
    );
    await reload();
  }

  LoanCard _card(Loan loan) => LoanCard(
        loan: loan,
        onTap: () => _openDetail(loan),
        onEdit: () => _editLoan(loan),
        onDelete: () => _deleteLoan(loan),
        onRepay: () => _repay(loan),
      );

  List<Widget> _section(String title, List<Loan> loans) {
    if (loans.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      ...loans.map(_card),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final settled = _loans.where((l) => l.isSettled).toList();

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (_loans.isEmpty)
            EmptyState(title: t.noLoans, subtitle: t.noLoansSub)
          else
            LoanSummaryCard(
              owedToMe: _owed(LoanDirection.lent),
              iOwe: _owed(LoanDirection.borrowed),
            ),
          const SizedBox(height: 8),
          ..._section(t.owedToMe, _open(LoanDirection.lent)),
          ..._section(t.iOwe, _open(LoanDirection.borrowed)),
          if (settled.isNotEmpty)
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text('${t.settledLoans} (${settled.length})'),
              children: settled.map(_card).toList(),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addLoan,
            icon: const Icon(Icons.add),
            label: Text(t.addLoan),
            style: OutlinedButton.styleFrom(
              foregroundColor: pal.green,
              side: BorderSide(color: pal.green, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
