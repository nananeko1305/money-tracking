import 'money_currency.dart';

/// A single dated money movement: an expense recorded against a category, a
/// savings deposit (positive) or withdrawal (negative), or a loan repayment.
class Transaction {
  final String id;
  final double amount;
  final String description;
  final String date; // ISO date string

  /// The movement's own currency, when its parent can hold several (a
  /// savings fund); null means the parent's currency.
  final MoneyCurrency? currency;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    this.currency,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: (json['description'] as String?) ?? '',
        date: json['date'] as String,
        currency: json['currency'] == null
            ? null
            : MoneyCurrency.fromName(json['currency'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'description': description,
        'date': date,
        if (currency case final c?) 'currency': c.name,
      };
}
