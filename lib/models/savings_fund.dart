import 'money_currency.dart';
import 'transaction.dart';

/// A savings pot, such as an emergency fund or a holiday fund. One fund can
/// hold dinars and euros at once: each has its own opening balance and every
/// entry its own currency (deposits positive, withdrawals negative), and the
/// balances are kept per currency, never added together. The monthly rollover
/// never clears it.
class SavingsFund {
  final String id;
  String name;
  double target; // 0 = no goal; in [currency]
  final String color;

  /// The goal's currency, and the one deposits start in. Entries and opening
  /// balances recorded before funds held several currencies are in it.
  MoneyCurrency currency;

  /// Already saved before tracking began, per currency.
  Map<MoneyCurrency, double> openingBalances;
  final String createdAt; // ISO date string
  List<Transaction> entries;

  SavingsFund({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.target = 0,
    this.currency = MoneyCurrency.rsd,
    Map<MoneyCurrency, double>? openingBalances,
    List<Transaction>? entries,
  })  : openingBalances = openingBalances ?? {},
        entries = entries ?? [];

  MoneyCurrency currencyOf(Transaction entry) => entry.currency ?? currency;

  /// The currencies the fund holds money in, dinars first; just [currency]
  /// while it is still empty.
  List<MoneyCurrency> get currencies {
    final used = {
      for (final MapEntry(key: c, value: v) in openingBalances.entries)
        if (v != 0) c,
      for (final e in entries) currencyOf(e),
    };
    return used.isEmpty
        ? [currency]
        : [for (final c in MoneyCurrency.values) if (used.contains(c)) c];
  }

  double openingIn(MoneyCurrency c) => openingBalances[c] ?? 0;

  double balanceIn(MoneyCurrency c) => entries
      .where((e) => currencyOf(e) == c)
      .fold(openingIn(c), (sum, e) => sum + e.amount);

  bool get hasTarget => target > 0;

  /// Progress counts only the money in the goal's currency.
  double get percentOfTarget =>
      hasTarget ? (balanceIn(currency) / target) * 100 : 0;

  /// Net amount moved into this fund in [c] during the calendar month of
  /// [month]: deposits minus withdrawals. The opening balance never counts,
  /// so setting up an existing fund does not eat into the month's income.
  double netInMonth(DateTime month, MoneyCurrency c) => entries
      .where((e) => currencyOf(e) == c && _inMonth(e.date, month))
      .fold(0.0, (sum, e) => sum + e.amount);

  static bool _inMonth(String iso, DateTime month) {
    final d = DateTime.tryParse(iso)?.toLocal();
    return d != null && d.year == month.year && d.month == month.month;
  }

  factory SavingsFund.fromJson(Map<String, dynamic> json) {
    final currency = MoneyCurrency.fromName(json['currency'] as String?);
    final balances = json['openingBalances'] as Map<String, dynamic>?;
    return SavingsFund(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      createdAt: json['createdAt'] as String,
      target: (json['target'] as num?)?.toDouble() ?? 0,
      currency: currency,
      // Before funds held several currencies there was one opening balance,
      // in the fund's currency.
      openingBalances: balances != null
          ? {
              for (final MapEntry(key: name, value: v) in balances.entries)
                if (v != 0) MoneyCurrency.fromName(name): (v as num).toDouble(),
            }
          : {currency: (json['openingBalance'] as num?)?.toDouble() ?? 0},
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// The stored form of [balances] for a fund in [currency]: a value for
  /// every currency, 0 included, so an update overwrites the old ones whether
  /// or not the nested map is merged; plus the single value app versions
  /// from before funds held several currencies read.
  static Map<String, dynamic> openingFields(
    Map<MoneyCurrency, double> balances,
    MoneyCurrency currency,
  ) =>
      {
        'openingBalances': {
          for (final c in MoneyCurrency.values) c.name: balances[c] ?? 0,
        },
        'openingBalance': balances[currency] ?? 0,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'createdAt': createdAt,
        'target': target,
        'currency': currency.name,
        ...openingFields(openingBalances, currency),
        'entries': entries.map((e) => e.toJson()).toList(),
      };
}
