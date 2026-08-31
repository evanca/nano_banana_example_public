import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';
import 'plate_spine.dart';

/// The plate when a run halts.
class FailedPlate extends StatelessWidget {
  const FailedPlate({
    required this.headline,
    required this.detail,
    super.key,
  });

  /// e.g. "Plate 3 failed".
  final String headline;

  /// The real failure text.
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Press.rule,
          border: Border.all(color: Press.pink),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _PinkHatchPainter()),
            const Align(
              alignment: Alignment.center,
              child: PlateSpine(highlight: false),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _WarningDiamond(),
                      const SizedBox(height: 18),
                      Text(
                        headline.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Press.display(26).copyWith(height: 1.05),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        detail.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Press.mono(
                          size: 11,
                          color: Press.inkAt(0.55),
                          tracking: 0.14,
                        ).copyWith(height: 1.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rotated square with an upright exclamation mark.
class _WarningDiamond extends StatelessWidget {
  const _WarningDiamond();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(border: Border.all(color: Press.pink, width: 2)),
        child: Center(
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Text(
              '!',
              style: Press.display(30).copyWith(color: Press.pink),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinkHatchPainter extends CustomPainter {
  const _PinkHatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Press.pink.withValues(alpha: 0.13);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    final extent = size.width + size.height;
    for (var x = -extent; x < extent; x += 28) {
      canvas.drawRect(Rect.fromLTWH(x, -extent, 12, extent * 2), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PinkHatchPainter oldDelegate) => false;
}
