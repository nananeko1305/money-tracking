/// Strings for the weekly budget card, the weekly limit of a category and the
/// warning shown when an expense goes past either. Mixed into [AppStrings];
/// each language implements it in its own file.
mixin WeeklyStrings {
  String get weeklyBudget;
  String get weeklyBudgetHelp;
  String get weeklyBudgetHint;
  String get setWeeklyBudget;
  String get weeklyBudgetEmptyMsg;
  String get spentThisWeek;
  String get leftThisWeek;
  String get weeklyLimit;
  String get weeklyLimitHelp;
  String get thisWeek;

  /// "[spent] of [limit]", both already formatted with their currency.
  String weekOf(String spent, String limit);

  /// When the next week begins, [n] days from today (1 to 7).
  String newWeekIn(int n);

  /// [category] has gone past its weekly limit by [over].
  String overCategoryLimit(String category, String over);

  /// All spending together has gone past the weekly budget by [over].
  String overWeeklyBudget(String over);
}
