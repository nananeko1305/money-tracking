import 'money_currency.dart';

/// A recurring monthly expense, such as rent or a subscription, in dinars or
/// euros. Unlike category transactions, fixed costs are not cleared by the
/// monthly rollover.
class FixedCost {
  final String id;
  String name;
  double amount;
  MoneyCurrency currency;

  FixedCost({
    required this.id,
    required this.name,
    required this.amount,
    this.currency = MoneyCurrency.rsd,
  });

  factory FixedCost.fromJson(Map<String, dynamic> json) => FixedCost(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: MoneyCurrency.fromName(json['currency'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'currency': currency.name,
      };
}
