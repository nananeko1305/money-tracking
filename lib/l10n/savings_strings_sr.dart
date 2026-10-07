import 'savings_strings.dart';

/// Serbian (Latin) savings strings.
mixin SavingsStringsSr implements SavingsStrings {
  @override
  String get navSavings => 'Štednja';
  @override
  String get totalSaved => 'Ukupno ušteđeno';
  @override
  String get savedThisMonth => 'Ovog meseca:';
  @override
  String get addSavings => 'Dodaj štednju';
  @override
  String get newSavings => 'Nova štednja';
  @override
  String get editSavings => 'Izmeni štednju';
  @override
  String get savingsNameHint => 'npr. Hitni fond';
  @override
  String get openingBalanceLabel => 'Početno stanje (opciono)';
  @override
  String get openingBalanceHelp => 'Koliko je već ušteđeno';
  @override
  String get openingBalance => 'Početno stanje:';
  @override
  String get savingsGoalLabel => 'Cilj (opciono)';
  @override
  String get savingsGoalHint => 'npr. 200000';
  @override
  String get savingsGoal => 'Cilj:';
  @override
  String get savingsBalance => 'Stanje:';
  @override
  String get deposit => 'Uplati';
  @override
  String get withdraw => 'Podigni';
  @override
  String get depositTitle => 'Uplata u štednju';
  @override
  String get withdrawTitle => 'Podizanje iz štednje';
  @override
  String get depositEntry => 'Uplata';
  @override
  String get withdrawalEntry => 'Podizanje';
  @override
  String get invalidSavings => 'Unesi naziv i validne iznose';
  @override
  String get insufficientSavings => 'Na štednji nema toliko novca';
  @override
  String get noSavings => 'Još nema štednje';
  @override
  String get noSavingsSub =>
      'Dodaj fond, npr. Hitni fond ili Letovanje, i beleži uplate i podizanja.';
  @override
  String get noSavingsEntries => 'Nema uplata ni podizanja';
  @override
  String get savingsNotFound => 'Štednja nije pronađena';
  @override
  String get deleteSavingsTitle => 'Obriši štednju';

  @override
  String deleteSavingsMsg(String fundName) =>
      'Da li želiš da obrišeš "$fundName" zajedno sa celom istorijom?';

  @override
  String goalProgress(String percent) => '$percent% cilja';
}
