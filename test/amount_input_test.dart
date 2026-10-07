import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/l10n/amount_input.dart';
import 'package:budget_tracker/l10n/strings.dart';

void main() {
  test('prefill text has no grouping separators', () {
    expect(amountInputText(40000), '40000');
    expect(amountInputText(12.5), '12.5');
    expect(amountInputText(0.1), '0.1');
    expect(amountInputText(100), '100');
  });

  test('prefill round-trips in Serbian, where display groups with "."', () {
    // The Serbian display format would have turned 40000 into 40.
    expect(AppStrings.of('sr').amount(40000), '40.000');
    for (final v in [40000.0, 1234.56, 0.5, 120000.0]) {
      expect(parseAmountInput(amountInputText(v)), v);
    }
  });

  test('parse accepts comma decimals and spaces, rejects junk', () {
    expect(parseAmountInput('12,5'), 12.5);
    expect(parseAmountInput(' 120 000 '), 120000);
    expect(parseAmountInput('abc'), isNull);
    expect(parseAmountInput(''), isNull);
  });
}
