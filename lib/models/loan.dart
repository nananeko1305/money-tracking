import 'dart:math';

import 'loan_direction.dart';
import 'money_currency.dart';
import 'transaction.dart';

/// Money lent to or borrowed from someone, with the repayments recorded so
/// far, all in the loan's [currency]. Loans live outside the monthly budget
/// and survive the rollover.
class Loan {
  final String id;
  String person;
  LoanDirection direction;
  MoneyCurrency currency;
  double amount;
  String note;
  final String date; // ISO date string, when the loan was made
  List<Transaction> repayments;

  Loan({
    required this.id,
    required this.person,
    required this.direction,
    required this.amount,
    required this.date,
    this.currency = MoneyCurrency.rsd,
    this.note = '',
    List<Transaction>? repayments,
  }) : repayments = repayments ?? [];

  double get repaid => repayments.fold(0.0, (sum, r) => sum + r.amount);

  /// What is still owed; never negative, even if the amount was edited below
  /// what has already been repaid.
  double get remaining => max(0.0, amount - repaid);

  /// Settled once less than one para is left, so floating point noise from
  /// decimal repayments cannot keep a loan open.
  bool get isSettled => remaining < 0.01;

  double get percentRepaid => amount > 0 ? (repaid / amount) * 100 : 0;

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'] as String,
        person: json['person'] as String,
        direction: LoanDirection.fromName(json['direction'] as String?),
        currency: MoneyCurrency.fromName(json['currency'] as String?),
        amount: (json['amount'] as num).toDouble(),
        date: json['date'] as String,
        note: (json['note'] as String?) ?? '',
        repayments: (json['repayments'] as List<dynamic>?)
                ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'person': person,
        'direction': direction.name,
        'currency': currency.name,
        'amount': amount,
        'date': date,
        'note': note,
        'repayments': repayments.map((r) => r.toJson()).toList(),
      };
}
