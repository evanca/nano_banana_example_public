import 'package:flutter/rendering.dart';

import '../../../../shared/theme/automat_colors.dart';

/// Corner targeting brackets, rule-of-thirds guides and a centre crosshair.
class ReticlePainter extends CustomPainter {
  const ReticlePainter({required this.bracketColor});

  final Color bracketColor;

  static const _inset = 16.0;
  static const _arm = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final guides = Paint()
      ..color = AutomatColors.reticleFaint
      ..strokeWidth = 1;
    for (final f in const [1 / 3, 2 / 3]) {
      canvas
        ..drawLine(Offset(size.width * f, 0), Offset(size.width * f, size.height), guides)
        ..drawLine(Offset(0, size.height * f), Offset(size.width, size.height * f), guides);
    }

    final cross = Paint()
      ..color = AutomatColors.reticle
      ..strokeWidth = 1;
    final c = size.center(Offset.zero);
    canvas
      ..drawLine(c - const Offset(12, 0), c + const Offset(12, 0), cross)
      ..drawLine(c - const Offset(0, 12), c + const Offset(0, 12), cross);

    final bracket = Paint()
      ..color = bracketColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final r = Rect.fromLTRB(_inset, _inset, size.width - _inset, size.height - _inset);
    for (final (corner, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + dx * _arm, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + dy * _arm),
        bracket,
      );
    }
  }

  @override
  bool shouldRepaint(ReticlePainter oldDelegate) => oldDelegate.bracketColor != bracketColor;
}
