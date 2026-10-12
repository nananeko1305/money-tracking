import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/money_currency.dart';
import '../models/savings_fund.dart';
import '../models/transaction.dart';
import '../services/savings_repository.dart';
import '../theme.dart';
import '../widgets/amount_row.dart';
import '../widgets/transaction_list.dart';

/// Shows the deposit / withdrawal history of one savings fund and allows
/// deleting individual entries.
class SavingsDetailScreen extends StatefulWidget {
  final SavingsRepository storage;
  final String fundId;

  const SavingsDetailScreen({
    super.key,
    required this.storage,
    required this.fundId,
  });

  @override
  State<SavingsDetailScreen> createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends State<SavingsDetailScreen> {
  SavingsFund? _fund;
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
    final funds = await widget.storage.funds();
    if (!mounted) return;
    setState(() {
      _fund = funds.where((f) => f.id == widget.fundId).firstOrNull;
      _loading = false;
    });
  }

  Future<void> _deleteEntry(Transaction entry) async {
    await widget.storage.deleteEntry(widget.fundId, entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final fund = _fund;

    return Scaffold(
      appBar: AppBar(title: Text(fund?.name ?? t.navSavings)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : fund == null
              ? Center(child: Text(t.savingsNotFound))
              : _buildBody(context, fund),
    );
  }

  Widget _buildBody(BuildContext context, SavingsFund fund) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hexColor(fund.color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (final (i, c) in fund.currencies.indexed)
                AmountRow(i == 0 ? t.savingsBalance : '',
                    t.money(fund.balanceIn(c), c),
                    color: pal.positive, emphasized: true),
              for (final (i, c) in _openingCurrencies(fund).indexed) ...[
                if (i == 0) const SizedBox(height: 6),
                AmountRow(i == 0 ? t.openingBalance : '',
                    t.money(fund.openingIn(c), c)),
              ],
              if (fund.hasTarget) ...[
                const SizedBox(height: 6),
                AmountRow(t.savingsGoal, t.money(fund.target, fund.currency)),
              ],
            ],
          ),
        ),
        Expanded(
          child: TransactionList(
            transactions: fund.entries,
            emptyText: t.noSavingsEntries,
            titleOf: (e) => e.description.isNotEmpty
                ? e.description
                : e.amount >= 0
                    ? t.depositEntry
                    : t.withdrawalEntry,
            amountOf: (e) => t.signedMoney(e.amount, fund.currencyOf(e)),
            colorOf: (e) => e.amount >= 0 ? pal.positive : pal.spent,
            onDelete: _deleteEntry,
          ),
        ),
      ],
    );
  }

  List<MoneyCurrency> _openingCurrencies(SavingsFund fund) => [
        for (final c in MoneyCurrency.values)
          if (fund.openingIn(c) > 0) c,
      ];
}
