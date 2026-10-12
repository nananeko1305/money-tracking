/// The currency an amount is kept in. Everything that holds money (categories
/// and their expenses, income, fixed costs, savings, loans, lists) is in
/// dinars or euros. Amounts in different currencies are never added
/// together, and there is no exchange rate: totals are kept per currency.
enum MoneyCurrency {
  rsd,
  eur;

  /// Parses a stored [name], falling back to [rsd]: everything recorded
  /// before currencies existed was in dinars.
  static MoneyCurrency fromName(String? name) =>
      values.asNameMap()[name] ?? rsd;
}
