import 'checklist_strings.dart';

/// Serbian (Latin) checklist strings.
mixin ChecklistStringsSr implements ChecklistStrings {
  @override
  String get navChecklists => 'Spiskovi';
  @override
  String get addChecklist => 'Dodaj spisak';
  @override
  String get newChecklist => 'Novi spisak';
  @override
  String get renameChecklist => 'Preimenuj spisak';
  @override
  String get checklistNameHint => 'npr. Market';
  @override
  String get invalidChecklist => 'Unesi naziv spiska';
  @override
  String get noChecklists => 'Nema spiskova';
  @override
  String get noChecklistsSub =>
      'Napravi spisak za market, šoping, more ili delove koje treba da kupiš.';
  @override
  String get checklistNotFound => 'Spisak nije pronađen';
  @override
  String get deleteChecklistTitle => 'Obriši spisak';
  @override
  String get addItem => 'Dodaj stavku';
  @override
  String get newItem => 'Nova stavka';
  @override
  String get editItem => 'Izmeni stavku';
  @override
  String get itemNameHint => 'npr. Mleko';
  @override
  String get itemAmountLabel => 'Planirani iznos (opciono)';
  @override
  String get invalidItem => 'Unesi naziv stavke i ispravan iznos';
  @override
  String get noItems => 'Spisak je prazan';
  @override
  String get noItemsSub => 'Dodaj šta treba da se kupi ili uradi.';
  @override
  String get checklistTotal => 'Ukupno:';
  @override
  String get deleteItemTitle => 'Obriši stavku';

  @override
  String deleteChecklistMsg(String name) =>
      'Obrisati spisak "$name" sa svim stavkama?';

  @override
  String deleteItemMsg(String name) => 'Obrisati "$name" sa spiska?';

  @override
  String itemsDone(int done, int total) => '$done od $total';
}
