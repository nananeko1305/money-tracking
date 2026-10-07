import 'category.dart';
import 'fixed_cost.dart';
import 'monthly_report.dart';

/// The full persisted application state.
class AppData {
  List<Category> currentCategories;
  List<MonthlyReport> monthlyReports;
  List<FixedCost> fixedCosts;
  String lastResetDate; // ISO date string

  AppData({
    required this.currentCategories,
    required this.monthlyReports,
    required this.lastResetDate,
    List<FixedCost>? fixedCosts,
  }) : fixedCosts = fixedCosts ?? [];

  factory AppData.empty() => AppData(
        currentCategories: [],
        monthlyReports: [],
        lastResetDate: DateTime.now().toIso8601String(),
      );

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        currentCategories: (json['currentCategories'] as List<dynamic>?)
                ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        monthlyReports: (json['monthlyReports'] as List<dynamic>?)
                ?.map((e) => MonthlyReport.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        // Absent in stores and backups made before fixed costs existed.
        fixedCosts: (json['fixedCosts'] as List<dynamic>?)
                ?.map((e) => FixedCost.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        lastResetDate: (json['lastResetDate'] as String?) ??
            DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        'currentCategories':
            currentCategories.map((c) => c.toJson()).toList(),
        'monthlyReports': monthlyReports.map((r) => r.toJson()).toList(),
        'fixedCosts': fixedCosts.map((c) => c.toJson()).toList(),
        'lastResetDate': lastResetDate,
      };
}
