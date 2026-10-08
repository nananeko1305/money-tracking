import 'loan.dart';
import 'loan_direction.dart';
import 'money_currency.dart';

/// What is still owed both ways in one currency, over the open loans.
class LoanTotals {
  const LoanTotals({
    required this.currency,
    required this.owedToMe,
    required this.iOwe,
  });

  final MoneyCurrency currency;
  final double owedToMe;
  final double iOwe;

  double get net => owedToMe - iOwe;

  /// One entry per currency that at least one of [loans] uses, dinars first.
  static List<LoanTotals> of(Iterable<Loan> loans) {
    double owed(MoneyCurrency c, LoanDirection d) => loans
        .where((l) => l.currency == c && l.direction == d && !l.isSettled)
        .fold(0.0, (s, l) => s + l.remaining);
    return [
      for (final c in MoneyCurrency.values)
        if (loans.any((l) => l.currency == c))
          LoanTotals(
            currency: c,
            owedToMe: owed(c, LoanDirection.lent),
            iOwe: owed(c, LoanDirection.borrowed),
          ),
    ];
  }
}
