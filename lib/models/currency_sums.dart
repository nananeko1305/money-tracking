import 'money_currency.dart';

/// Adds up [items] per currency: one entry for every currency at least one
/// item uses, dinars first. Amounts in different currencies are never added
/// together.
Map<MoneyCurrency, double> sumByCurrency<T>(
  Iterable<T> items,
  MoneyCurrency Function(T) currencyOf,
  double Function(T) amountOf,
) =>
    {
      for (final c in MoneyCurrency.values)
        if (items.any((i) => currencyOf(i) == c))
          c: items
              .where((i) => currencyOf(i) == c)
              .fold(0.0, (sum, i) => sum + amountOf(i)),
    };
