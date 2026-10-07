/// Which way the money of a loan went.
enum LoanDirection {
  /// The user lent the money: the other person owes them.
  lent,

  /// The user borrowed the money: they owe the other person.
  borrowed;

  /// Parses a stored [name], falling back to [lent] for unknown values.
  static LoanDirection fromName(String? name) =>
      values.asNameMap()[name] ?? lent;
}
