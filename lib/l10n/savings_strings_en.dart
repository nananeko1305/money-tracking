import 'savings_strings.dart';

/// English savings strings.
mixin SavingsStringsEn implements SavingsStrings {
  @override
  String get navSavings => 'Savings';
  @override
  String get totalSaved => 'Total saved';
  @override
  String get savedThisMonth => 'This month:';
  @override
  String get addSavings => 'Add savings';
  @override
  String get newSavings => 'New savings';
  @override
  String get editSavings => 'Edit savings';
  @override
  String get savingsNameHint => 'e.g. Emergency fund';
  @override
  String get openingBalanceLabel => 'Opening balance (optional)';
  @override
  String get openingBalanceHelp => 'What you have already saved';
  @override
  String get openingBalance => 'Opening balance:';
  @override
  String get savingsGoalLabel => 'Goal (optional)';
  @override
  String get savingsGoalHint => 'e.g. 200000';
  @override
  String get savingsGoal => 'Goal:';
  @override
  String get savingsBalance => 'Balance:';
  @override
  String get deposit => 'Deposit';
  @override
  String get withdraw => 'Withdraw';
  @override
  String get depositTitle => 'Deposit to savings';
  @override
  String get withdrawTitle => 'Withdraw from savings';
  @override
  String get depositEntry => 'Deposit';
  @override
  String get withdrawalEntry => 'Withdrawal';
  @override
  String get invalidSavings => 'Enter a name and valid amounts';
  @override
  String get insufficientSavings => 'There is not that much in savings';
  @override
  String get noSavings => 'No savings yet';
  @override
  String get noSavingsSub =>
      'Add a fund, like an emergency fund or a holiday, and record deposits and withdrawals.';
  @override
  String get noSavingsEntries => 'No deposits or withdrawals yet';
  @override
  String get savingsNotFound => 'Savings not found';
  @override
  String get deleteSavingsTitle => 'Delete savings';

  @override
  String deleteSavingsMsg(String fundName) =>
      'Delete "$fundName" together with its whole history?';

  @override
  String goalProgress(String percent) => '$percent% of goal';
}
