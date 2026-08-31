import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// The dashed fold down the middle of a plate.
class PlateSpine extends StatelessWidget {
  const PlateSpine({this.highlight = true, super.key});

  /// The pressing plate catches light on the fold; the failed plate is flat.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 9,
      child: CustomPaint(
        painter: _SpinePainter(highlight: highlight),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SpinePainter extends CustomPainter {
  const _SpinePainter({required this.highlight});

  final bool highlight;

  static const double _segment = 15;

  @override
  void paint(Canvas canvas, Size size) {
    final dark = Paint()..color = Press.ink.withValues(alpha: 0.22);
    final light = Paint()..color = Colors.white.withValues(alpha: 0.2);
    for (var y = 0.0; y < size.height; y += _segment * 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, _segment), dark);
      if (highlight) {
        canvas.drawRect(Rect.fromLTWH(0, y + _segment, size.width, 1), light);
      }
    }
  }

  @override
  bool shouldRepaint(_SpinePainter oldDelegate) =>
      oldDelegate.highlight != highlight;
}
