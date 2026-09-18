import '../models/app_data.dart';
import '../models/monthly_report.dart';

/// The monthly reset rule. When the calendar month has advanced past
/// [AppData.lastResetDate], the previous month is archived as a
/// [MonthlyReport] and the live categories keep their structure but lose their
/// recorded transactions. Pure logic — it never touches persistence.
class MonthlyRollover {
  const MonthlyRollover();

  static String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Mutates [data] in place if a new month has begun. Returns true when a
  /// rollover was performed, so the caller knows it must persist the change.
  bool apply(AppData data, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final lastReset = DateTime.tryParse(data.lastResetDate) ?? current;
    final lastResetMonth = _monthKey(lastReset);

    if (lastResetMonth == _monthKey(current) ||
        data.currentCategories.isEmpty) {
      return false;
    }

    final totalBudget =
        data.currentCategories.fold(0.0, (s, c) => s + c.budget);
    final totalSpent =
        data.currentCategories.fold(0.0, (s, c) => s + c.spent);

    final report = MonthlyReport(
      id: lastResetMonth,
      month: lastResetMonth,
      categories: data.currentCategories.map((c) => c.copy()).toList(),
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      totalRemaining: totalBudget - totalSpent,
      savedAt: current.toIso8601String(),
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
