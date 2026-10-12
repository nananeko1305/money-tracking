import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/money_currency.dart';
import '../theme.dart';

/// The summary card atop the fixed costs list: the sum of all fixed costs for
/// one month, one line per currency.
class FixedCostsTotalCard extends StatelessWidget {
  final Map<MoneyCurrency, double> totals;

  const FixedCostsTotalCard({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.subtleFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The label gives way, so a long amount never overflows the card.
          Expanded(
            child: Text(
              t.fixedCostsTotal,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final MapEntry(key: currency, value: total)
                  in totals.entries)
                Text(
                  t.money(total, currency),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: pal.spent,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
