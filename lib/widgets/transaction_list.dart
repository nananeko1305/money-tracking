import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/transaction.dart';
import '../theme.dart';

/// A dated history of money movements, newest first. Swiping a row left
/// deletes it. The caller decides how each row is titled and how its amount
/// is shown, so the same list serves expenses, savings entries and loan
/// repayments.
class TransactionList extends StatefulWidget {
  final List<Transaction> transactions;
  final String emptyText;
  final String Function(Transaction) titleOf;
  final String Function(Transaction) amountOf;
  final Color Function(Transaction) colorOf;
  final ValueChanged<Transaction> onDelete;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.emptyText,
    required this.titleOf,
    required this.amountOf,
    required this.colorOf,
    required this.onDelete,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  /// Rows swiped away whose deletion has not come back from the data yet.
  /// Writes are not awaited, so without this a rebuild in between would put
  /// a dismissed row back, which Flutter does not allow.
  final Set<String> _dismissed = {};

  @override
  void didUpdateWidget(TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final present = {for (final t in widget.transactions) t.id};
    _dismissed.removeWhere((id) => !present.contains(id));
  }

  void _dismiss(Transaction tx) {
    setState(() => _dismissed.add(tx.id));
    widget.onDelete(tx);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final sorted = [
      for (final tx in widget.transactions)
        if (!_dismissed.contains(tx.id)) tx,
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (sorted.isEmpty) {
      return Center(
        child: Text(widget.emptyText, style: const TextStyle(fontSize: 15)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final tx = sorted[i];
        return Dismissible(
          key: ValueKey(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: pal.danger,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _dismiss(tx),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              widget.titleOf(tx),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(t.dateTime(tx.date)),
            trailing: Text(
              widget.amountOf(tx),
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: widget.colorOf(tx)),
            ),
          ),
        );
      },
    );
  }
}
