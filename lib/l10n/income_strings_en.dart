import 'income_strings.dart';

/// English income strings.
mixin IncomeStringsEn implements IncomeStrings {
  @override
  String get monthlyIncome => 'Monthly income';
  @override
  String get incomeHelp => 'Salary and any other income for the month';
  @override
  String get incomeHint => 'e.g. 120000';
  @override
  String get setIncome => 'Set income';
  @override
  String get incomeEmptyMsg =>
      'Enter your salary or total budget for the month to see how much is still unallocated.';
  @override
  String get allocated => 'Allocated to categories:';
  @override
  String get savingsThisMonth => 'Savings this month:';
  @override
  String get unallocated => 'Unallocated:';
  @override
  String get leftOfIncome => 'Left of income:';
  @override
  String get reportIncome => 'Income:';
  @override
  String get reportSaved => 'Saved:';
}
