import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/savings_fund.dart';
import '../services/savings_repository.dart';
import '../theme.dart';
import '../widgets/amount_entry_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/savings_fund_card.dart';
import '../widgets/savings_fund_form_dialog.dart';
import '../widgets/savings_summary_card.dart';
import 'savings_detail_screen.dart';

/// The "Savings" section: the total across funds, one card per fund with
/// deposit / withdraw actions, and adding new funds.
class SavingsScreen extends StatefulWidget {
  final SavingsRepository storage;

  const SavingsScreen({super.key, required this.storage});

  @override
  State<SavingsScreen> createState() => SavingsScreenState();
}

class SavingsScreenState extends State<SavingsScreen> {
  List<SavingsFund> _funds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final funds = await widget.storage.funds();
    if (!mounted) return;
    setState(() {
      _funds = funds;
      _loading = false;
    });
  }

  double get _total => _funds.fold(0.0, (s, f) => s + f.balance);
  double get _thisMonth =>
      _funds.fold(0.0, (s, f) => s + f.netInMonth(DateTime.now()));

  Future<void> _addFund() async {
    final result = await showSavingsFundFormDialog(context);
    if (result == null) return;
    await widget.storage.addFund(result.name,
        target: result.target, openingBalance: result.openingBalance);
    await reload();
  }

  Future<void> _editFund(SavingsFund fund) async {
    final result = await showSavingsFundFormDialog(context, existing: fund);
    if (result == null) return;
    await widget.storage.updateFund(fund.id,
        name: result.name,
        target: result.target,
        openingBalance: result.openingBalance);
    await reload();
  }

  Future<void> _deleteFund(SavingsFund fund) async {
    final t = AppScope.of(context).strings;
    final confirmed = await showConfirmDialog(
      context,
      title: t.deleteSavingsTitle,
      message: t.deleteSavingsMsg(fund.name),
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await widget.storage.deleteFund(fund.id);
    await reload();
  }

  Future<void> _deposit(SavingsFund fund) async {
    final t = AppScope.of(context).strings;
    final entry = await showAmountEntryDialog(context,
        title: t.depositTitle, confirmLabel: t.deposit);
    if (entry == null) return;
    await widget.storage.deposit(fund.id, entry.amount, entry.description);
    await reload();
  }

  Future<void> _withdraw(SavingsFund fund) async {
    final t = AppScope.of(context).strings;
    final messenger = ScaffoldMessenger.of(context);
    final entry = await showAmountEntryDialog(context,
        title: t.withdrawTitle, confirmLabel: t.withdraw);
    if (entry == null) return;
    if (entry.amount > fund.balance + 0.005) {
      messenger.showSnackBar(SnackBar(content: Text(t.insufficientSavings)));
      return;
    }
    await widget.storage.withdraw(fund.id, entry.amount, entry.description);
    await reload();
  }

  Future<void> _openDetail(SavingsFund fund) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SavingsDetailScreen(storage: widget.storage, fundId: fund.id),
      ),
    );
    await reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (_funds.isEmpty)
            EmptyState(title: t.noSavings, subtitle: t.noSavingsSub)
          else ...[
            SavingsSummaryCard(total: _total, thisMonth: _thisMonth),
            const SizedBox(height: 16),
          ],
          ..._funds.map((fund) => SavingsFundCard(
                fund: fund,
                onTap: () => _openDetail(fund),
                onEdit: () => _editFund(fund),
                onDelete: () => _deleteFund(fund),
                onDeposit: () => _deposit(fund),
                onWithdraw: () => _withdraw(fund),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addFund,
            icon: const Icon(Icons.add),
            label: Text(t.addSavings),
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
