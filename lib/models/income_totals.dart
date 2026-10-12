import 'budget_totals.dart';
import 'money_currency.dart';

/// One currency's monthly income against what is planned, spent and saved
/// out of it. Every amount is in [currency]; nothing crosses currencies.
class IncomeTotals {
  const IncomeTotals({
    required this.currency,
    required this.income,
    required this.allocated,
    required this.spent,
    required this.saved,
  });

  final MoneyCurrency currency;
  final double income;
  final double allocated; // category budgets
  final double spent;
  final double saved; // net moved into savings this month

  double get unallocated => income - allocated - saved;
  double get left => income - spent - saved;

  /// How much of the income is used up, between 0 and 1.
  double get usedShare =>
      income > 0 ? ((spent + saved) / income).clamp(0.0, 1.0) : 0;

  /// One entry per currency with an income set, dinars first.
  static List<IncomeTotals> of({
    required double Function(MoneyCurrency) incomeIn,
    required List<BudgetTotals> budgets,
    required Map<MoneyCurrency, double> saved,
  }) =>
      [
        for (final c in MoneyCurrency.values)
          if (incomeIn(c) > 0)
            IncomeTotals(
              currency: c,
              income: incomeIn(c),
              allocated:
                  budgets.where((b) => b.currency == c).firstOrNull?.budget ?? 0,
              spent:
                  budgets.where((b) => b.currency == c).firstOrNull?.spent ?? 0,
              saved: saved[c] ?? 0,
            ),
      ];
}
