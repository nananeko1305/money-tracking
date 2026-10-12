import 'category.dart';
import 'checklist.dart';
import 'fixed_cost.dart';
import 'loan.dart';
import 'money_currency.dart';
import 'monthly_report.dart';
import 'savings_fund.dart';

/// The full persisted application state.
class AppData {
  List<Category> currentCategories;
  List<MonthlyReport> monthlyReports;
  List<FixedCost> fixedCosts;
  String lastResetDate; // ISO date string
  double monthlyIncome; // dinars; 0 = not set; carries over between months
  double monthlyIncomeEur; // euros; 0 = not set
  List<SavingsFund> savingsFunds;
  List<Loan> loans;
  List<Checklist> checklists;

  AppData({
    required this.currentCategories,
    required this.monthlyReports,
    required this.lastResetDate,
    List<FixedCost>? fixedCosts,
    this.monthlyIncome = 0,
    this.monthlyIncomeEur = 0,
    List<SavingsFund>? savingsFunds,
    List<Loan>? loans,
    List<Checklist>? checklists,
  })  : fixedCosts = fixedCosts ?? [],
        savingsFunds = savingsFunds ?? [],
        loans = loans ?? [],
        checklists = checklists ?? [];

  factory AppData.empty() => AppData(
        currentCategories: [],
        monthlyReports: [],
        lastResetDate: DateTime.now().toIso8601String(),
      );

  /// True when nothing has been recorded yet, as on a fresh install.
  bool get isEmpty =>
      currentCategories.isEmpty &&
      monthlyReports.isEmpty &&
      fixedCosts.isEmpty &&
      savingsFunds.isEmpty &&
      loans.isEmpty &&
      checklists.isEmpty &&
      monthlyIncome == 0 &&
      monthlyIncomeEur == 0;

  /// The monthly income in [currency]; 0 when it is not set.
  double incomeIn(MoneyCurrency currency) => switch (currency) {
        MoneyCurrency.rsd => monthlyIncome,
        MoneyCurrency.eur => monthlyIncomeEur,
      };

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        currentCategories: (json['currentCategories'] as List<dynamic>?)
                ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        monthlyReports: (json['monthlyReports'] as List<dynamic>?)
                ?.map((e) => MonthlyReport.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        // Absent in on-phone data saved before fixed costs existed.
        fixedCosts: (json['fixedCosts'] as List<dynamic>?)
                ?.map((e) => FixedCost.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        lastResetDate: (json['lastResetDate'] as String?) ??
            DateTime.now().toIso8601String(),
        // Income, savings and loans are absent in on-phone data saved before
        // they existed.
        monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
        monthlyIncomeEur:
            (json['monthlyIncomeEur'] as num?)?.toDouble() ?? 0,
        savingsFunds: (json['savingsFunds'] as List<dynamic>?)
                ?.map((e) => SavingsFund.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        loans: (json['loans'] as List<dynamic>?)
                ?.map((e) => Loan.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        // Absent in on-phone data: lists came after accounts.
        checklists: (json['checklists'] as List<dynamic>?)
                ?.map((e) => Checklist.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'currentCategories':
            currentCategories.map((c) => c.toJson()).toList(),
        'monthlyReports': monthlyReports.map((r) => r.toJson()).toList(),
        'fixedCosts': fixedCosts.map((c) => c.toJson()).toList(),
        'lastResetDate': lastResetDate,
        'monthlyIncome': monthlyIncome,
        'monthlyIncomeEur': monthlyIncomeEur,
        'savingsFunds': savingsFunds.map((f) => f.toJson()).toList(),
        'loans': loans.map((l) => l.toJson()).toList(),
        'checklists': checklists.map((c) => c.toJson()).toList(),
      };
}
