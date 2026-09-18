import 'package:flutter/material.dart';

import '../theme.dart';

/// The "days until the monthly reset" banner shown atop the dashboard.
class DaysBanner extends StatelessWidget {
  final String text;
  const DaysBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final pal = palette(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pal.bannerBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_bottom, size: 18, color: pal.bannerFg),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: pal.bannerFg,
            ),
          ),
        ],
      ),
    );
  }
}
