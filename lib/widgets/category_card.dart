import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/category.dart';
import '../theme.dart';
import 'amount_row.dart';
import 'category_week_row.dart';

/// A single category card on the dashboard: budget summary, progress bar, the
/// week against its weekly limit (when it has one) and an inline expense
/// entry field.
class CategoryCard extends StatefulWidget {
  final Category category;

  /// What the category has spent this week.
  final double weekSpent;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(double amount, String description) onAddExpense;

  const CategoryCard({
    super.key,
    required this.category,
    this.weekSpent = 0,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAddExpense,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final t = AppScope.of(context).strings;
    final amount = parseAmountInput(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidAmount)),
      );
      return;
    }
    widget.onAddExpense(amount, _descController.text);
    _amountController.clear();
    _descController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final category = widget.category;
    final color = hexColor(category.color);
    final percent = category.percentageSpent;
    final remaining = category.remaining;

    final Color barColor = percent > 100
        ? pal.danger
        : percent > 80
            ? pal.warning
            : color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.onTap,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${category.transactions.length}',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
                ),
                const Icon(Icons.chevron_right, size: 20),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close, size: 20, color: pal.danger),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _infoRow(t.budget, t.money(category.budget, category.currency), null),
          _infoRow(
            t.spent,
            '${t.money(category.spent, category.currency)} (${percent.toStringAsFixed(0)}%)',
            pal.spent,
          ),
          _infoRow(
            t.remaining,
            t.money(remaining, category.currency),
            remaining < 0 ? pal.danger : pal.positive,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: pal.subtleFill,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          if (category.weeklyLimit > 0) ...[
            const SizedBox(height: 12),
            CategoryWeekRow(
              spent: widget.weekSpent,
              limit: category.weeklyLimit,
              currency: category.currency,
              color: color,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: t.amountHint,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    hintText: t.descHint,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: _submit,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The shared [AmountRow] lets the label give way, so a long amount never
  /// overflows the card.
  Widget _infoRow(String label, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AmountRow(label, value, color: color),
    );
  }
}
