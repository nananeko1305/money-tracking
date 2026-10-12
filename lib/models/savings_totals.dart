import 'money_currency.dart';
import 'savings_fund.dart';

/// The savings in one currency: the balance across all funds and the net
/// amount moved into them during a month. A fund that holds dinars and euros
/// counts in both.
class SavingsTotals {
  const SavingsTotals({
    required this.currency,
    required this.balance,
    required this.thisMonth,
  });

  final MoneyCurrency currency;
  final double balance;
  final double thisMonth;

  /// One entry per currency that at least one of [funds] holds, dinars
  /// first; [thisMonth] covers the calendar month of [month].
  static List<SavingsTotals> of(Iterable<SavingsFund> funds, DateTime month) {
    Iterable<SavingsFund> holding(MoneyCurrency c) =>
        funds.where((f) => f.currencies.contains(c));
    return [
      for (final c in MoneyCurrency.values)
        if (holding(c).isNotEmpty)
          SavingsTotals(
            currency: c,
            balance: holding(c).fold(0.0, (s, f) => s + f.balanceIn(c)),
            thisMonth:
                holding(c).fold(0.0, (s, f) => s + f.netInMonth(month, c)),
          ),
    ];
  }
}
