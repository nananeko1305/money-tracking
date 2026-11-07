import 'weekly_strings.dart';

/// English weekly budget strings.
mixin WeeklyStringsEn implements WeeklyStrings {
  @override
  String get weeklyBudget => 'Weekly budget';
  @override
  String get weeklyBudgetHelp => 'What you may spend from Monday to Sunday';
  @override
  String get weeklyBudgetHint => 'e.g. 15000';
  @override
  String get setWeeklyBudget => 'Set a weekly budget';
  @override
  String get weeklyBudgetEmptyMsg =>
      'Enter what you may spend in one week, across all categories. A week starts on Monday.';
  @override
  String get spentThisWeek => 'Spent this week:';
  @override
  String get leftThisWeek => 'Left this week:';
  @override
  String get weeklyLimit => 'Weekly limit';
  @override
  String get weeklyLimitHelp => 'Leave empty for no weekly limit';
  @override
  String get thisWeek => 'This week:';

  @override
  String weekOf(String spent, String limit) => '$spent of $limit';

  @override
  String newWeekIn(int n) =>
      n == 1 ? 'A new week starts tomorrow' : 'New week in $n days';

  @override
  String overCategoryLimit(String category, String over) =>
      '$category: $over over the weekly limit';

  @override
  String overWeeklyBudget(String over) => 'Weekly budget: $over over';
}
