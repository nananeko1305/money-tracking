/// The currency an amount is kept in. The monthly budget is always in dinars;
/// loans can also be in euros. Amounts in different currencies are never
/// added together, and there is no exchange rate.
enum MoneyCurrency {
  rsd,
  eur;

  /// Parses a stored [name], falling back to [rsd]: everything recorded
  /// before currencies existed was in dinars.
  static MoneyCurrency fromName(String? name) =>
      values.asNameMap()[name] ?? rsd;
}
