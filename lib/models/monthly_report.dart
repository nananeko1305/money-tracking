import 'category.dart';

/// A saved snapshot of one month's budget.
class MonthlyReport {
  final String id;
  final String month; // "YYYY-MM"
  final List<Category> categories;
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final String savedAt; // ISO date string

  const MonthlyReport({
    required this.id,
    required this.month,
    required this.categories,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.savedAt,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) => MonthlyReport(
        id: json['id'] as String,
        month: json['month'] as String,
        categories: (json['categories'] as List<dynamic>)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalBudget: (json['totalBudget'] as num).toDouble(),
        totalSpent: (json['totalSpent'] as num).toDouble(),
        totalRemaining: (json['totalRemaining'] as num).toDouble(),
        savedAt: json['savedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'month': month,
        'categories': categories.map((c) => c.toJson()).toList(),
        'totalBudget': totalBudget,
        'totalSpent': totalSpent,
        'totalRemaining': totalRemaining,
        'savedAt': savedAt,
      };
}
