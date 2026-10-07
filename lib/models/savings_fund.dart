import 'transaction.dart';

/// A savings pot, such as an emergency fund or a holiday fund. Its balance is
/// the opening balance plus every recorded entry: deposits are positive
/// amounts, withdrawals negative. The monthly rollover never clears it.
class SavingsFund {
  final String id;
  String name;
  double target; // 0 = no goal
  double openingBalance; // already saved before tracking began
  final String color;
  final String createdAt; // ISO date string
  List<Transaction> entries;

  SavingsFund({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.target = 0,
    this.openingBalance = 0,
    List<Transaction>? entries,
  }) : entries = entries ?? [];

  double get balance =>
      entries.fold(openingBalance, (sum, e) => sum + e.amount);

  bool get hasTarget => target > 0;

  double get percentOfTarget => hasTarget ? (balance / target) * 100 : 0;

  /// Net amount moved into this fund during the calendar month of [month]:
  /// deposits minus withdrawals. The opening balance never counts, so setting
  /// up an existing fund does not eat into the current month's income.
  double netInMonth(DateTime month) => entries
      .where((e) => _inMonth(e.date, month))
      .fold(0.0, (sum, e) => sum + e.amount);

  static bool _inMonth(String iso, DateTime month) {
    final d = DateTime.tryParse(iso)?.toLocal();
    return d != null && d.year == month.year && d.month == month.month;
  }

  factory SavingsFund.fromJson(Map<String, dynamic> json) => SavingsFund(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as String,
        createdAt: json['createdAt'] as String,
        target: (json['target'] as num?)?.toDouble() ?? 0,
        openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0,
        entries: (json['entries'] as List<dynamic>?)
                ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'createdAt': createdAt,
        'target': target,
        'openingBalance': openingBalance,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
}
