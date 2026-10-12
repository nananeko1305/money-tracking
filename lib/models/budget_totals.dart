import 'category.dart';
import 'currency_sums.dart';
import 'money_currency.dart';

/// The budget in one currency: what its categories plan and have spent.
class BudgetTotals {
  const BudgetTotals({
    required this.currency,
    required this.budget,
    required this.spent,
  });

  final MoneyCurrency currency;
  final double budget;
  final double spent;

  double get remaining => budget - spent;

  /// One entry per currency that at least one of [categories] uses, dinars
  /// first.
  static List<BudgetTotals> of(Iterable<Category> categories) {
    final budgets = sumByCurrency(categories, (c) => c.currency, (c) => c.budget);
    final spent = sumByCurrency(categories, (c) => c.currency, (c) => c.spent);
    return [
      for (final MapEntry(key: currency, value: budget) in budgets.entries)
        BudgetTotals(
          currency: currency,
          budget: budget,
          spent: spent[currency] ?? 0,
        ),
    ];
  }
}
