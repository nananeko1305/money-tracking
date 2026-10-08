/// Strings for the checklists (lists of things to buy or do). Mixed into
/// [AppStrings]; each language implements it in its own file.
mixin ChecklistStrings {
  String get navChecklists;
  String get addChecklist;
  String get newChecklist;
  String get renameChecklist;
  String get checklistNameHint;
  String get invalidChecklist;
  String get noChecklists;
  String get noChecklistsSub;
  String get checklistNotFound;
  String get deleteChecklistTitle;
  String get addItem;
  String get newItem;
  String get editItem;
  String get itemNameHint;
  String get itemAmountLabel;
  String get invalidItem;
  String get noItems;
  String get noItemsSub;
  String get checklistTotal;
  String get deleteItemTitle;

  String deleteChecklistMsg(String name);
  String deleteItemMsg(String name);
  String itemsDone(int done, int total);
}
