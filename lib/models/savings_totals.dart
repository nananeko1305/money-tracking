import 'money_currency.dart';
import 'savings_fund.dart';

/// The savings in one currency: the balance across its funds and the net
/// amount moved into them during a month.
class SavingsTotals {
  const SavingsTotals({
    required this.currency,
    required this.balance,
    required this.thisMonth,
  });

  final MoneyCurrency currency;
  final double balance;
  final double thisMonth;

  /// One entry per currency that at least one of [funds] uses, dinars first;
  /// [thisMonth] covers the calendar month of [month].
  static List<SavingsTotals> of(Iterable<SavingsFund> funds, DateTime month) {
    Iterable<SavingsFund> inCurrency(MoneyCurrency c) =>
        funds.where((f) => f.currency == c);
    return [
      for (final c in MoneyCurrency.values)
        if (inCurrency(c).isNotEmpty)
          SavingsTotals(
            currency: c,
            balance: inCurrency(c).fold(0.0, (s, f) => s + f.balance),
            thisMonth:
                inCurrency(c).fold(0.0, (s, f) => s + f.netInMonth(month)),
          ),
    ];
  }
}
