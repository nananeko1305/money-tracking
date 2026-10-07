/// A recurring monthly expense, such as rent or a subscription. Unlike category
/// transactions, fixed costs are not cleared by the monthly rollover.
class FixedCost {
  final String id;
  String name;
  double amount;

  FixedCost({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory FixedCost.fromJson(Map<String, dynamic> json) => FixedCost(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
      };
}
