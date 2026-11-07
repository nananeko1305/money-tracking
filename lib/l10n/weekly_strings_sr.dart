import 'weekly_strings.dart';

/// Serbian (Latin) weekly budget strings.
mixin WeeklyStringsSr implements WeeklyStrings {
  @override
  String get weeklyBudget => 'Nedeljni budžet';
  @override
  String get weeklyBudgetHelp => 'Koliko smeš da potrošiš od ponedeljka do nedelje';
  @override
  String get weeklyBudgetHint => 'npr. 15000';
  @override
  String get setWeeklyBudget => 'Postavi nedeljni budžet';
  @override
  String get weeklyBudgetEmptyMsg =>
      'Upiši koliko smeš da potrošiš u jednoj nedelji, za sve kategorije zajedno. Nedelja počinje u ponedeljak.';
  @override
  String get spentThisWeek => 'Potrošeno ove nedelje:';
  @override
  String get leftThisWeek => 'Ostalo za ovu nedelju:';
  @override
  String get weeklyLimit => 'Nedeljni limit';
  @override
  String get weeklyLimitHelp => 'Prazno znači bez nedeljnog limita';
  @override
  String get thisWeek => 'Ove nedelje:';

  @override
  String weekOf(String spent, String limit) => '$spent od $limit';

  @override
  String newWeekIn(int n) =>
      n == 1 ? 'Nova nedelja počinje sutra' : 'Nova nedelja za $n dana';

  @override
  String overCategoryLimit(String category, String over) =>
      '$category: $over preko nedeljnog limita';

  @override
  String overWeeklyBudget(String over) => 'Nedeljni budžet: $over preko';
}
