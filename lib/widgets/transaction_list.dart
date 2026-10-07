import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/transaction.dart';
import '../theme.dart';

/// A dated history of money movements, newest first. Swiping a row left
/// deletes it. The caller decides how each row is titled and how its amount
/// is shown, so the same list serves expenses, savings entries and loan
/// repayments.
class TransactionList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

    if (sorted.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(fontSize: 15)),
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
          onDismissed: (_) => onDelete(tx),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              titleOf(tx),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(t.dateTime(tx.date)),
            trailing: Text(
              amountOf(tx),
              style: TextStyle(fontWeight: FontWeight.w600, color: colorOf(tx)),
            ),
          ),
        );
      },
    );
  }
}
