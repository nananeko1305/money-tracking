import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/budget_repository.dart';
import '../theme.dart';

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
    _load();
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
    await _load();
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
    final transactions = [...category.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

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
          child: transactions.isEmpty
              ? Center(
                  child: Text(
                    t.noTransactions,
                    style: const TextStyle(fontSize: 15),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final tx = transactions[i];
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: pal.danger,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteTransaction(tx),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          tx.description.isEmpty ? t.expense : tx.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(t.dateTime(tx.date)),
                        trailing: Text(
                          t.din(tx.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: pal.spent,
                          ),
                        ),
                      ),
                    );
                  },
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
