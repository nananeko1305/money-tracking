import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/money_currency.dart';
import '../theme.dart';

/// The Dinars / Euros switch of every money form.
class CurrencySelector extends StatelessWidget {
  final MoneyCurrency selected;
  final ValueChanged<MoneyCurrency> onChanged;

  const CurrencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<MoneyCurrency>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: pal.green,
          selectedForegroundColor: Colors.white,
        ),
        segments: [
          ButtonSegment(value: MoneyCurrency.rsd, label: Text(t.dinars)),
          ButtonSegment(value: MoneyCurrency.eur, label: Text(t.euros)),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
