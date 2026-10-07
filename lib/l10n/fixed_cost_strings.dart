/// Strings for the fixed costs section. Mixed into [AppStrings]; each language
/// implements it in its own file.
mixin FixedCostStrings {
  String get navFixedCosts;
  // Bottom navigation label: the full name does not fit next to four tabs.
  String get navFixedCostsShort;
  String get fixedCostsTotal;
  String get addFixedCost;
  String get newFixedCost;
  String get editFixedCost;
  String get fixedCostNameHint;
  String get fixedCostAmountHint;
  String get invalidFixedCost;
  String get noFixedCosts;
  String get noFixedCostsSub;
  String get deleteFixedCostTitle;
  String deleteFixedCostMsg(String costName);
}
