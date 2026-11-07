import 'money_currency.dart';
import 'transaction.dart';

/// A budget category with its recorded transactions, all in the category's
/// [currency].
class Category {
  final String id;
  String name;
  double budget;

  /// What the category may spend in one week (Monday to Sunday); 0 means it
  /// has no weekly limit.
  double weeklyLimit;
  final String color;
  final String createdAt; // ISO date string
  MoneyCurrency currency;
  List<Transaction> transactions;

  Category({
    required this.id,
    required this.name,
    required this.budget,
    this.weeklyLimit = 0,
    required this.color,
    required this.createdAt,
    this.currency = MoneyCurrency.rsd,
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
        // Absent in categories made before weekly limits existed.
        weeklyLimit: (json['weeklyLimit'] as num?)?.toDouble() ?? 0,
        color: json['color'] as String,
        createdAt: json['createdAt'] as String,
        currency: MoneyCurrency.fromName(json['currency'] as String?),
        transactions: (json['transactions'] as List<dynamic>?)
                ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'budget': budget,
        'weeklyLimit': weeklyLimit,
        'spent': spent, // stored for report snapshots / interop
        'color': color,
        'createdAt': createdAt,
        'currency': currency.name,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  Category copy() => Category(
        id: id,
        name: name,
        budget: budget,
        weeklyLimit: weeklyLimit,
        color: color,
        createdAt: createdAt,
        currency: currency,
        transactions: transactions
            .map((t) => Transaction.fromJson(t.toJson()))
            .toList(),
      );
}
