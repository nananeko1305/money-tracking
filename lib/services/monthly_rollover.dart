import '../models/app_data.dart';
import '../models/budget_totals.dart';
import '../models/currency_sums.dart';
import '../models/money_currency.dart';
import '../models/month_key.dart';
import '../models/monthly_report.dart';
import '../models/report_totals.dart';

/// The monthly reset rule. When the calendar month has advanced past
/// [AppData.lastResetDate], the previous month is archived as a
/// [MonthlyReport] and the live categories keep their structure but lose their
/// recorded transactions. Income, savings and loans carry over untouched; the
/// report only snapshots, per currency, the income and what was saved that
/// month. Pure logic — it never touches persistence.
class MonthlyRollover {
  const MonthlyRollover();

  /// Mutates [data] in place if a new month has begun. Returns true when a
  /// rollover was performed, so the caller knows it must persist the change.
  bool apply(AppData data, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final lastReset = DateTime.tryParse(data.lastResetDate) ?? current;
    final lastResetMonth = monthKey(lastReset);

    if (lastResetMonth == monthKey(current) ||
        data.currentCategories.isEmpty) {
      return false;
    }

    final budgets = BudgetTotals.of(data.currentCategories);
    final saved = sumByCurrency(data.savingsFunds, (f) => f.currency,
        (f) => f.netInMonth(lastReset));
    BudgetTotals? budgetIn(MoneyCurrency c) =>
        budgets.where((b) => b.currency == c).firstOrNull;

    final report = MonthlyReport(
      id: lastResetMonth,
      month: lastResetMonth,
      categories: data.currentCategories.map((c) => c.copy()).toList(),
      savedAt: current.toIso8601String(),
      // Each currency on its own: its categories, its income and its
      // savings. Nothing is converted.
      totals: {
        for (final c in MoneyCurrency.values)
          if (budgetIn(c) != null ||
              data.incomeIn(c) > 0 ||
              (saved[c] ?? 0) != 0)
            c: ReportTotals(
              budget: budgetIn(c)?.budget ?? 0,
              spent: budgetIn(c)?.spent ?? 0,
              income: data.incomeIn(c),
              saved: saved[c] ?? 0,
            ),
      },
    );

    // Keep category structure, clear the recorded transactions.
    for (final c in data.currentCategories) {
      c.transactions = [];
    }

    data.monthlyReports = [report, ...data.monthlyReports].take(12).toList();
    data.lastResetDate = current.toIso8601String();
    return true;
  }

  /// Days remaining until the first of next month.
  int daysUntilReset({DateTime? now}) {
    final current = now ?? DateTime.now();
    final nextMonth = DateTime(current.year, current.month + 1, 1);
    return nextMonth.difference(current).inHours ~/ 24 + 1;
  }
}
