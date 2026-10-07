import 'package:flutter/material.dart';

/// One "label .... amount" line of a summary card. [emphasized] renders it
/// bold and slightly larger, for the line that matters most.
class AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool emphasized;

  const AmountRow(
    this.label,
    this.value, {
    super.key,
    this.color,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = emphasized ? 15.0 : 14.0;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: size,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
