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
