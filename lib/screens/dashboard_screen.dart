import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/category.dart';
import '../services/budget_repository.dart';
import '../theme.dart';
import '../widgets/category_card.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/days_banner.dart';
import '../widgets/totals_card.dart';
import 'category_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final BudgetRepository storage;

  const DashboardScreen({super.key, required this.storage});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<Category> _categories = [];
  int _daysRemaining = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final cats = await widget.storage.currentCategories();
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _daysRemaining = widget.storage.daysUntilReset();
      _loading = false;
    });
  }

  double get _totalBudget => _categories.fold(0.0, (s, c) => s + c.budget);
  double get _totalSpent => _categories.fold(0.0, (s, c) => s + c.spent);

  Future<void> _addCategory() async {
    final result = await showCategoryFormDialog(context);
    if (result == null) return;
    await widget.storage.addCategory(result.name, result.budget);
    await reload();
  }

  Future<void> _editCategory(Category category) async {
    final result = await showCategoryFormDialog(context, existing: category);
    if (result == null) return;
    await widget.storage
        .updateCategory(category.id, name: result.name, budget: result.budget);
    await reload();
  }

  Future<void> _deleteCategory(Category category) async {
    final t = AppScope.of(context).strings;
    final confirmed = await showConfirmDialog(
      context,
      title: t.deleteCategoryTitle,
      message: t.deleteCategoryMsg(category.name),
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await widget.storage.deleteCategory(category.id);
    await reload();
  }

  Future<void> _addExpense(Category category, double amount, String desc) async {
    await widget.storage.addExpense(category.id, amount, desc);
    await reload();
  }

  Future<void> _openDetail(Category category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(
          storage: widget.storage,
          categoryId: category.id,
        ),
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

    final totalRemaining = _totalBudget - _totalSpent;

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          DaysBanner(text: t.daysUntilReset(_daysRemaining)),
          const SizedBox(height: 16),
          if (_categories.isNotEmpty) ...[
            TotalsCard(
              totalBudget: _totalBudget,
              totalSpent: _totalSpent,
              totalRemaining: totalRemaining,
            ),
            const SizedBox(height: 16),
          ],
          ..._categories.map((category) => CategoryCard(
                category: category,
                onTap: () => _openDetail(category),
                onEdit: () => _editCategory(category),
                onDelete: () => _deleteCategory(category),
                onAddExpense: (amount, desc) =>
                    _addExpense(category, amount, desc),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
            label: Text(t.addCategory),
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
