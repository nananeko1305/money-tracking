import 'category.dart';
import 'money_currency.dart';
import 'month_key.dart';
import 'monthly_report.dart';
import 'week.dart';

/// How far one more expense goes past the weekly limits; 0 means it stays
/// within that limit, or there is no limit.
typedef WeeklyOverrun = ({double category, double budget});

/// What was spent in the current week (Monday to Sunday), per category and
/// per currency.
///
/// A week that began in the previous month counts that month's expenses too:
/// closing a month deletes its expenses, but its report keeps a copy, so they
/// are read back from there. An expense found in both places counts once.
class WeeklySpending {
  const WeeklySpending._(this.daysLeft, this._byCategory, this._byCurrency);

  /// Nothing spent; what the screen shows before the data has loaded.
  static const WeeklySpending none = WeeklySpending._(DateTime.daysPerWeek, {}, {});

  /// Days until the next week begins.
  final int daysLeft;
  final Map<String, double> _byCategory;
  final Map<MoneyCurrency, double> _byCurrency;

  factory WeeklySpending.of(
    List<Category> categories,
    List<MonthlyReport> reports, {
    required DateTime now,
  }) {
    final start = weekStart(now);
    final end = DateTime(start.year, start.month, start.day + DateTime.daysPerWeek);
    final startMonth = monthKey(start);
    final sources = [
      ...categories,
      for (final r in reports)
        if (r.month.compareTo(startMonth) >= 0) ...r.categories,
    ];

    final seen = <String>{};
    final byCategory = <String, double>{};
    final byCurrency = <MoneyCurrency, double>{};
    for (final c in sources) {
      for (final t in c.transactions) {
        final date = DateTime.tryParse(t.date);
        if (date == null || date.isBefore(start) || !date.isBefore(end)) continue;
        if (!seen.add(t.id)) continue;
        byCategory[c.id] = (byCategory[c.id] ?? 0) + t.amount;
        byCurrency[c.currency] = (byCurrency[c.currency] ?? 0) + t.amount;
      }
    }
    return WeeklySpending._(daysUntilNextWeek(now), byCategory, byCurrency);
  }

  double inCategory(String categoryId) => _byCategory[categoryId] ?? 0;

  double inCurrency(MoneyCurrency currency) => _byCurrency[currency] ?? 0;

  /// How far an expense of [amount] in [category] would go past the
  /// category's weekly limit and past [budget], the weekly budget of the
  /// category's currency.
  WeeklyOverrun overrunAfter(
    Category category,
    double amount, {
    required double budget,
  }) {
    double over(double limit, double spent) =>
        limit > 0 && spent + amount > limit ? spent + amount - limit : 0;
    return (
      category: over(category.weeklyLimit, inCategory(category.id)),
      budget: over(budget, inCurrency(category.currency)),
    );
  }
}
