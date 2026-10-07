/// Strings for the savings section. Mixed into [AppStrings]; each language
/// implements it in its own file.
mixin SavingsStrings {
  String get navSavings;
  String get totalSaved;
  String get savedThisMonth;
  String get addSavings;
  String get newSavings;
  String get editSavings;
  String get savingsNameHint;
  String get openingBalanceLabel;
  String get openingBalanceHelp;
  String get openingBalance;
  String get savingsGoalLabel;
  String get savingsGoalHint;
  String get savingsGoal;
  String get savingsBalance;
  String get deposit;
  String get withdraw;
  String get depositTitle;
  String get withdrawTitle;
  String get depositEntry;
  String get withdrawalEntry;
  String get invalidSavings;
  String get insufficientSavings;
  String get noSavings;
  String get noSavingsSub;
  String get noSavingsEntries;
  String get savingsNotFound;
  String get deleteSavingsTitle;

  String deleteSavingsMsg(String fundName);
  String goalProgress(String percent);
}
