import 'package:flutter/material.dart';

import '../theme.dart';

/// A progress bar for [spent] out of [limit] that turns to the warning color
/// past 80 % and to the danger color past the limit, like a category's
/// monthly bar.
class SpendingBar extends StatelessWidget {
  final double spent;
  final double limit;
  final Color color;
  final double height;

  const SpendingBar({
    super.key,
    required this.spent,
    required this.limit,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palette(context);
    final share = limit > 0 ? spent / limit : 0.0;
    final barColor = share > 1
        ? pal.danger
        : share > 0.8
            ? pal.warning
            : color;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: share.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: pal.subtleFill,
        valueColor: AlwaysStoppedAnimation(barColor),
      ),
    );
  }
}
