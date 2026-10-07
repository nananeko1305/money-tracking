/// Text for prefilling an amount input field. Unlike [AppStrings.amount] it
/// has no grouping separators, so [parseAmountInput] reads it back as the same
/// value in every locale (Serbian groups thousands with '.', so "40.000" would
/// otherwise parse as 40). E.g. 40000 -> "40000", 12.5 -> "12.5".
String amountInputText(double value) =>
    value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

/// Parses the text of an amount input field, accepting ',' as the decimal
/// separator and ignoring spaces. Returns null when it is not a number.
double? parseAmountInput(String text) =>
    double.tryParse(text.replaceAll(' ', '').replaceAll(',', '.'));
