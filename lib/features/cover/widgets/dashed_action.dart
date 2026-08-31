import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// Dashed-outline secondary action, e.g. "Upload a photo".
class DashedAction extends StatelessWidget {
  const DashedAction({
    required this.label,
    required this.onPressed,
    this.leading,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: onPressed,
        child: CustomPaint(
          painter: const _DashedBorderPainter(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 10)],
                Text(label.toUpperCase(), style: Press.mono(size: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Press.inkAt(0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dash = 5.0;
    const gap = 4.0;
    void line(Offset from, Offset to) {
      final total = (to - from).distance;
      final dir = (to - from) / total;
      var travelled = 0.0;
      while (travelled < total) {
        final end = (travelled + dash).clamp(0.0, total);
        canvas.drawLine(from + dir * travelled, from + dir * end, paint);
        travelled += dash + gap;
      }
    }

    line(Offset.zero, Offset(size.width, 0));
    line(Offset(size.width, 0), Offset(size.width, size.height));
    line(Offset(size.width, size.height), Offset(0, size.height));
    line(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
