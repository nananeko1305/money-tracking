import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import '../models/budget.dart';
import '../services/storage.dart';
import '../theme.dart';
import '../widgets/category_card.dart';
import 'category_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final BudgetStorage storage;

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
    final result = await _showCategoryDialog();
    if (result == null) return;
    await widget.storage.addCategory(result.name, result.budget);
    await reload();
  }

  Future<void> _editCategory(Category category) async {
    final result = await _showCategoryDialog(existing: category);
    if (result == null) return;
    await widget.storage
        .updateCategory(category.id, name: result.name, budget: result.budget);
    await reload();
  }

  Future<void> _deleteCategory(Category category) async {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteCategoryTitle),
        content: Text(t.deleteCategoryMsg(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: pal.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
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

  Future<_CategoryFormResult?> _showCategoryDialog({Category? existing}) {
    final t = AppScope.of(context).strings;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final budgetController = TextEditingController(
        text: existing != null ? t.amount(existing.budget) : '');

    return showDialog<_CategoryFormResult>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? t.newCategory : t.editCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: t.name,
                hintText: t.nameHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: t.budget.replaceAll(':', ''),
                hintText: t.budgetHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final budget = double.tryParse(
                  budgetController.text.trim().replaceAll(',', '.'));
              if (name.isEmpty || budget == null || budget <= 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(t.invalidCategory),
                ));
                return;
              }
              Navigator.pop(ctx, _CategoryFormResult(name, budget));
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
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
          _DaysBanner(text: t.daysUntilReset(_daysRemaining), pal: pal),
          const SizedBox(height: 16),
          if (_categories.isNotEmpty) ...[
            _TotalsCard(
              t: t,
              pal: pal,
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

class _CategoryFormResult {
  final String name;
  final double budget;
  const _CategoryFormResult(this.name, this.budget);
}

class _DaysBanner extends StatelessWidget {
  final String text;
  final AppPalette pal;
  const _DaysBanner({required this.text, required this.pal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pal.bannerBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_bottom, size: 18, color: pal.bannerFg),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: pal.bannerFg,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final AppStrings t;
  final AppPalette pal;
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;

  const _TotalsCard({
    required this.t,
    required this.pal,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.subtleFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        children: [
          _row(t.totalBudget, t.din(totalBudget), null),
          const SizedBox(height: 8),
          _row(t.totalSpent, t.din(totalSpent), pal.spent),
          const SizedBox(height: 8),
          _row(
            t.remaining,
            t.din(totalRemaining),
            totalRemaining < 0 ? pal.danger : pal.positive,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color? color) {
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
