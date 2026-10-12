/// A closed month's numbers in one currency.
class ReportTotals {
  const ReportTotals({
    this.budget = 0,
    this.spent = 0,
    this.income = 0,
    this.saved = 0,
  });

  final double budget;
  final double spent;
  final double income; // 0 when no income was set
  final double saved; // net moved into savings during the month

  double get remaining => budget - spent;

  double get percentSpent => budget > 0 ? (spent / budget) * 100 : 0;

  bool get isZero => budget == 0 && spent == 0 && income == 0 && saved == 0;

  factory ReportTotals.fromJson(Map<String, dynamic> json) => ReportTotals(
        budget: (json['budget'] as num?)?.toDouble() ?? 0,
        spent: (json['spent'] as num?)?.toDouble() ?? 0,
        income: (json['income'] as num?)?.toDouble() ?? 0,
        saved: (json['saved'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'budget': budget,
        'spent': spent,
        'income': income,
        'saved': saved,
      };
}
