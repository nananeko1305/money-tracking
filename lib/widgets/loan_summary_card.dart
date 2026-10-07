import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The loans overview: what others still owe the user, what the user still
/// owes, and the net of the two.
class LoanSummaryCard extends StatelessWidget {
  final double owedToMe;
  final double iOwe;

  const LoanSummaryCard({
    super.key,
    required this.owedToMe,
    required this.iOwe,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final net = owedToMe - iOwe;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.subtleFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        children: [
          AmountRow('${t.owedToMe}:', t.din(owedToMe), color: pal.positive),
          const SizedBox(height: 8),
          AmountRow('${t.iOwe}:', t.din(iOwe), color: pal.danger),
          const Divider(height: 20),
          AmountRow(
            t.loansNet,
            t.signedDin(net),
            color: net < 0 ? pal.danger : pal.positive,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}
