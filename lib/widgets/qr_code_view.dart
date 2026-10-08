import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// [data] as a QR code: black modules on white with the standard quiet zone,
/// in light and dark theme alike, so any camera can read it.
class QrCodeView extends StatelessWidget {
  final String data;
  final double size;

  const QrCodeView({super.key, required this.data, this.size = 220});

  @override
  Widget build(BuildContext context) {
    final image = QrImage(QrCode(
      payload: QrPayload.fromString(data),
      errorCorrectLevel: QrErrorCorrectLevel.medium,
    ));
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _QrPainter(image)),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);

  final QrImage image;

  /// Modules of white margin on every side, as the QR standard asks.
  static const int _quietZone = 4;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final count = image.moduleCount;
    final module = size.width / (count + 2 * _quietZone);
    final modules = Path();
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (!image.isDark(row, col)) continue;
        modules.addRect(Rect.fromLTWH((col + _quietZone) * module,
            (row + _quietZone) * module, module, module));
      }
    }
    // One path without anti-aliasing: a module rarely spans whole device
    // pixels, and blended edges leave light seams between neighbours that
    // cameras can misread.
    canvas.drawPath(
      modules,
      Paint()
        ..color = Colors.black
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.image != image;
}
