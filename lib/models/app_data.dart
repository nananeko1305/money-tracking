import 'category.dart';
import 'loan.dart';
import 'monthly_report.dart';
import 'savings_fund.dart';

/// The full persisted application state.
class AppData {
  List<Category> currentCategories;
  List<MonthlyReport> monthlyReports;
  String lastResetDate; // ISO date string
  double monthlyIncome; // 0 = not set; carries over between months
  List<SavingsFund> savingsFunds;
  List<Loan> loans;

  AppData({
    required this.currentCategories,
    required this.monthlyReports,
    required this.lastResetDate,
    this.monthlyIncome = 0,
    List<SavingsFund>? savingsFunds,
    List<Loan>? loans,
  })  : savingsFunds = savingsFunds ?? [],
        loans = loans ?? [];

  factory AppData.empty() => AppData(
        currentCategories: [],
        monthlyReports: [],
        lastResetDate: DateTime.now().toIso8601String(),
      );

  /// True when nothing has been recorded yet, as on a fresh install.
  bool get isEmpty =>
      currentCategories.isEmpty &&
      monthlyReports.isEmpty &&
      savingsFunds.isEmpty &&
      loans.isEmpty &&
      monthlyIncome == 0;

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        currentCategories: (json['currentCategories'] as List<dynamic>?)
                ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        monthlyReports: (json['monthlyReports'] as List<dynamic>?)
                ?.map((e) => MonthlyReport.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        lastResetDate: (json['lastResetDate'] as String?) ??
            DateTime.now().toIso8601String(),
        // Income, savings and loans are absent in stores and backups made
        // before they existed.
        monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
        savingsFunds: (json['savingsFunds'] as List<dynamic>?)
                ?.map((e) => SavingsFund.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        loans: (json['loans'] as List<dynamic>?)
                ?.map((e) => Loan.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'currentCategories':
            currentCategories.map((c) => c.toJson()).toList(),
        'monthlyReports': monthlyReports.map((r) => r.toJson()).toList(),
        'lastResetDate': lastResetDate,
        'monthlyIncome': monthlyIncome,
        'savingsFunds': savingsFunds.map((f) => f.toJson()).toList(),
        'loans': loans.map((l) => l.toJson()).toList(),
      };
}
