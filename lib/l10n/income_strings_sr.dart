import 'income_strings.dart';

/// Serbian (Latin) income strings.
mixin IncomeStringsSr implements IncomeStrings {
  @override
  String get monthlyIncome => 'Mesečni prihod';
  @override
  String get incomeHelp => 'Plata i ostali prihodi za mesec';
  @override
  String get incomeHint => 'npr. 120000';
  @override
  String get setIncome => 'Unesi prihod';
  @override
  String get incomeEmptyMsg =>
      'Unesi platu ili ukupan budžet za mesec da vidiš koliko je ostalo neraspoređeno.';
  @override
  String get allocated => 'Raspoređeno u kategorije:';
  @override
  String get savingsThisMonth => 'Štednja ovog meseca:';
  @override
  String get unallocated => 'Neraspoređeno:';
  @override
  String get leftOfIncome => 'Preostalo od prihoda:';
  @override
  String get reportIncome => 'Prihod:';
  @override
  String get reportSaved => 'Ušteđeno:';
}
