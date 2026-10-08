import 'checklist_strings.dart';

/// English checklist strings.
mixin ChecklistStringsEn implements ChecklistStrings {
  @override
  String get navChecklists => 'Lists';
  @override
  String get addChecklist => 'Add list';
  @override
  String get newChecklist => 'New list';
  @override
  String get renameChecklist => 'Rename list';
  @override
  String get checklistNameHint => 'e.g. Groceries';
  @override
  String get invalidChecklist => 'Enter a list name';
  @override
  String get noChecklists => 'No lists yet';
  @override
  String get noChecklistsSub =>
      'Make a list for groceries, shopping, a trip or parts you need to buy.';
  @override
  String get checklistNotFound => 'List not found';
  @override
  String get deleteChecklistTitle => 'Delete list';
  @override
  String get addItem => 'Add item';
  @override
  String get newItem => 'New item';
  @override
  String get editItem => 'Edit item';
  @override
  String get itemNameHint => 'e.g. Milk';
  @override
  String get itemAmountLabel => 'Planned amount (optional)';
  @override
  String get invalidItem => 'Enter an item name and a valid amount';
  @override
  String get noItems => 'The list is empty';
  @override
  String get noItemsSub => 'Add what needs to be bought or done.';
  @override
  String get checklistTotal => 'Total:';
  @override
  String get deleteItemTitle => 'Delete item';

  @override
  String deleteChecklistMsg(String name) =>
      'Delete the list "$name" with all its items?';

  @override
  String deleteItemMsg(String name) => 'Remove "$name" from the list?';

  @override
  String itemsDone(int done, int total) => '$done of $total';
}
