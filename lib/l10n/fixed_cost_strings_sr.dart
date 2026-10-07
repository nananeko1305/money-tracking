import 'fixed_cost_strings.dart';

/// Serbian (Latin) fixed costs strings.
mixin FixedCostStringsSr implements FixedCostStrings {
  @override
  String get navFixedCosts => 'Fiksni troškovi';
  @override
  String get navFixedCostsShort => 'Fiksni';
  @override
  String get fixedCostsTotal => 'Ukupno mesečno:';
  @override
  String get addFixedCost => 'Dodaj fiksni trošak';
  @override
  String get newFixedCost => 'Novi fiksni trošak';
  @override
  String get editFixedCost => 'Izmeni fiksni trošak';
  @override
  String get fixedCostNameHint => 'npr. Kirija';
  @override
  String get fixedCostAmountHint => 'npr. 30000';
  @override
  String get invalidFixedCost => 'Unesi validan naziv i iznos';
  @override
  String get noFixedCosts => 'Nema fiksnih troškova';
  @override
  String get noFixedCostsSub =>
      'Dodaj stavke koje plaćaš svakog meseca, npr. kiriju, struju ili internet.';
  @override
  String get deleteFixedCostTitle => 'Obriši fiksni trošak';

  @override
  String deleteFixedCostMsg(String costName) =>
      'Da li si siguran da želiš da obrišeš "$costName"?';
}
