import 'transaction.dart';

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
