import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/budget_repository.dart';
import '../theme.dart';
import '../widgets/transaction_list.dart';

/// Shows the transaction history for one category and allows deleting
/// individual transactions.
class CategoryDetailScreen extends StatefulWidget {
  final BudgetRepository storage;
  final String categoryId;

  const CategoryDetailScreen({
    super.key,
    required this.storage,
    required this.categoryId,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  Category? _category;
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
    final cats = await widget.storage.currentCategories();
    if (!mounted) return;
    setState(() {
      _category = cats.where((c) => c.id == widget.categoryId).firstOrNull;
      _loading = false;
    });
  }

  Future<void> _deleteTransaction(Transaction t) async {
    await widget.storage.deleteTransaction(widget.categoryId, t.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final category = _category;

    return Scaffold(
      appBar: AppBar(title: Text(category?.name ?? t.navBudget)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : category == null
              ? Center(child: Text(t.categoryNotFound))
              : _buildBody(context, category),
    );
  }

  Widget _buildBody(BuildContext context, Category category) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hexColor(category.color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _summaryRow(t.budget, t.din(category.budget), null),
              const SizedBox(height: 6),
              _summaryRow(t.spent, t.din(category.spent), pal.spent),
              const SizedBox(height: 6),
              _summaryRow(
                t.remaining,
                t.din(category.remaining),
                category.remaining < 0 ? pal.danger : pal.positive,
              ),
            ],
          ),
        ),
        Expanded(
          child: TransactionList(
            transactions: category.transactions,
            emptyText: t.noTransactions,
            titleOf: (tx) =>
                tx.description.isEmpty ? t.expense : tx.description,
            amountOf: (tx) => t.din(tx.amount),
            colorOf: (_) => pal.spent,
            onDelete: _deleteTransaction,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, Color? color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
