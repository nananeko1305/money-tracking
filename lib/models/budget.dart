// Data models for the budget tracking app.

/// A single expense recorded against a category.
class Transaction {
  final String id;
  final double amount;
  final String description;
  final String date; // ISO date string

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: (json['description'] as String?) ?? '',
        date: json['date'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'description': description,
        'date': date,
      };
}

/// A budget category with its recorded transactions.
class Category {
  final String id;
  String name;
  double budget;
  final String color;
  final String createdAt; // ISO date string
  List<Transaction> transactions;

  Category({
    required this.id,
    required this.name,
    required this.budget,
    required this.color,
    required this.createdAt,
    List<Transaction>? transactions,
  }) : transactions = transactions ?? [];

  /// Total spent, derived from the transaction list.
  double get spent =>
      transactions.fold(0.0, (sum, t) => sum + t.amount);

  double get remaining => budget - spent;

  double get percentageSpent =>
      budget > 0 ? (spent / budget) * 100 : 0;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        budget: (json['budget'] as num).toDouble(),
        color: json['color'] as String,
        createdAt: json['createdAt'] as String,
        transactions: (json['transactions'] as List<dynamic>?)
                ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'budget': budget,
        'spent': spent, // stored for report snapshots / interop
        'color': color,
        'createdAt': createdAt,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  Category copy() => Category(
        id: id,
        name: name,
        budget: budget,
        color: color,
        createdAt: createdAt,
        transactions: transactions
            .map((t) => Transaction.fromJson(t.toJson()))
            .toList(),
      );
}

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

/// The full persisted application state.
class AppData {
  List<Category> currentCategories;
  List<MonthlyReport> monthlyReports;
  String lastResetDate; // ISO date string

  AppData({
    required this.currentCategories,
    required this.monthlyReports,
    required this.lastResetDate,
  });

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
        lastResetDate: (json['lastResetDate'] as String?) ??
            DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        'currentCategories':
            currentCategories.map((c) => c.toJson()).toList(),
        'monthlyReports': monthlyReports.map((r) => r.toJson()).toList(),
        'lastResetDate': lastResetDate,
      };
}
