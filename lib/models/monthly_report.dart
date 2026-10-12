import 'category.dart';
import 'money_currency.dart';
import 'report_totals.dart';

/// A saved snapshot of one month's budget, with its numbers per currency.
class MonthlyReport {
  final String id;
  final String month; // "YYYY-MM"
  final List<Category> categories;
  final String savedAt; // ISO date string

  /// Only the currencies the month used, dinars first.
  final Map<MoneyCurrency, ReportTotals> totals;

  const MonthlyReport({
    required this.id,
    required this.month,
    required this.categories,
    required this.savedAt,
    this.totals = const {},
  });

  ReportTotals totalsIn(MoneyCurrency currency) =>
      totals[currency] ?? const ReportTotals();

  /// The dinar numbers keep the keys reports have always had, so older
  /// reports (all dinars, some from before income and savings existed) read
  /// as they are; euro numbers sit under 'eur'.
  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
    final dinars = ReportTotals(
      budget: (json['totalBudget'] as num?)?.toDouble() ?? 0,
      spent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      income: (json['income'] as num?)?.toDouble() ?? 0,
      // Absent in reports made before fixed costs counted against income.
      fixed: (json['fixedCosts'] as num?)?.toDouble() ?? 0,
      saved: (json['saved'] as num?)?.toDouble() ?? 0,
    );
    final euros = json['eur'] as Map<String, dynamic>?;
    final usesDinars = !dinars.isZero ||
        categories.any((c) => c.currency == MoneyCurrency.rsd);
    return MonthlyReport(
      id: json['id'] as String,
      month: json['month'] as String,
      categories: categories,
      savedAt: json['savedAt'] as String,
      totals: {
        if (usesDinars) MoneyCurrency.rsd: dinars,
        if (euros != null) MoneyCurrency.eur: ReportTotals.fromJson(euros),
      },
    );
  }

  Map<String, dynamic> toJson() {
    final dinars = totalsIn(MoneyCurrency.rsd);
    return {
      'id': id,
      'month': month,
      'categories': categories.map((c) => c.toJson()).toList(),
      'totalBudget': dinars.budget,
      'totalSpent': dinars.spent,
      'totalRemaining': dinars.remaining,
      'income': dinars.income,
      'fixedCosts': dinars.fixed,
      'saved': dinars.saved,
      if (totals[MoneyCurrency.eur] case final euros?) 'eur': euros.toJson(),
      'savedAt': savedAt,
    };
  }
}
