import 'fixed_cost_strings.dart';

/// English fixed costs strings.
mixin FixedCostStringsEn implements FixedCostStrings {
  @override
  String get navFixedCosts => 'Fixed costs';
  @override
  String get navFixedCostsShort => 'Fixed costs';
  @override
  String get fixedCostsTotal => 'Monthly total:';
  @override
  String get addFixedCost => 'Add fixed cost';
  @override
  String get newFixedCost => 'New fixed cost';
  @override
  String get editFixedCost => 'Edit fixed cost';
  @override
  String get fixedCostNameHint => 'e.g. Rent';
  @override
  String get fixedCostAmountHint => 'e.g. 30000';
  @override
  String get invalidFixedCost => 'Enter a valid name and amount';
  @override
  String get noFixedCosts => 'No fixed costs yet';
  @override
  String get noFixedCostsSub =>
      'Add the things you pay every month, like rent, utilities or internet.';
  @override
  String get deleteFixedCostTitle => 'Delete fixed cost';

  @override
  String deleteFixedCostMsg(String costName) =>
      'Are you sure you want to delete "$costName"?';
}
