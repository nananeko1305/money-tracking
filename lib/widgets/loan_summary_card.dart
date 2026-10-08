import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import '../models/loan_totals.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The loans overview: what others still owe the user, what the user still
/// owes, and the net of the two, one block per currency. Dinars and euros are
/// never added together; there is no exchange rate.
class LoanSummaryCard extends StatelessWidget {
  final List<LoanTotals> totals;

  const LoanSummaryCard({super.key, required this.totals});

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
      child: Column(
        children: [
          for (final (i, block) in totals.indexed) ...[
            if (i > 0) const Divider(height: 32, thickness: 1.5),
            ..._block(t, pal, block),
          ],
        ],
      ),
    );
  }

  List<Widget> _block(AppStrings t, AppPalette pal, LoanTotals x) => [
        AmountRow('${t.owedToMe}:', t.money(x.owedToMe, x.currency),
            color: pal.positive),
        const SizedBox(height: 8),
        AmountRow('${t.iOwe}:', t.money(x.iOwe, x.currency),
            color: pal.danger),
        const Divider(height: 20),
        AmountRow(
          t.loansNet,
          t.signedMoney(x.net, x.currency),
          color: x.net < 0 ? pal.danger : pal.positive,
          emphasized: true,
        ),
      ];
}
