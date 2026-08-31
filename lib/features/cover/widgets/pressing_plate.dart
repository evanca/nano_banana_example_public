import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';
import 'plate_spine.dart';

/// The plate while a cover is being generated.
class PressingPlate extends StatefulWidget {
  const PressingPlate({
    required this.stage,
    required this.stageIndex,
    required this.stageCount,
    super.key,
  });

  /// Current stage label.
  final String stage;

  /// Zero-based position of [stage].
  final int stageIndex;

  final int stageCount;

  @override
  State<PressingPlate> createState() => _PressingPlateState();
}

class _PressingPlateState extends State<PressingPlate>
    with TickerProviderStateMixin {
  late final _drift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();
  late final _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..repeat();

  @override
  void dispose() {
    _drift.dispose();
    _sweep.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ColoredBox(
        color: Press.rule,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _drift,
              builder: (context, _) => CustomPaint(
                painter: _HatchPainter(phase: _drift.value),
              ),
            ),
            AnimatedBuilder(
              animation: _sweep,
              builder: (context, child) {
                final curved = Curves.easeInOut.transform(_sweep.value);
                return FractionalTranslation(
                  // -120% to 320% of the band's own width.
                  translation: Offset(-1.2 + curved * 4.4, 0),
                  child: child,
                );
              },
              child: FractionallySizedBox(
                widthFactor: 0.26,
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.75),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Align(alignment: Alignment.center, child: PlateSpine()),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _spin,
                      builder: (context, _) => CustomPaint(
                        size: const Size.square(92),
                        painter: _DiscPainter(turns: _spin.value),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.stage.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Press.display(26).copyWith(height: 1.05),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'PLATES ${widget.stageIndex + 1} OF ${widget.stageCount}',
                      style: Press.mono(size: 10, color: Press.inkAt(0.5)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/// Diagonal hatch that slides sideways.
class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.phase});

  final double phase;

  static const double period = 28;
  static const double bandWidth = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Press.ink.withValues(alpha: 0.08);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // 135° stripes: drawn vertical, canvas rotated.
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    final extent = size.width + size.height;
    final offset = phase * period;
    for (var x = -extent + offset; x < extent; x += period) {
      canvas.drawRect(
        Rect.fromLTWH(x, -extent, bandWidth, extent * 2),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => oldDelegate.phase != phase;
}

/// The spinning disc: track, two-tone arc, hub.
class _DiscPainter extends CustomPainter {
  const _DiscPainter({required this.turns});

  final double turns;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.width / 2 - 1;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Press.ink.withValues(alpha: 0.16),
    );

    final rotation = turns * 2 * math.pi;
    void arc(double startFraction, Color colour) {
      canvas.drawArc(
        rect,
        rotation + startFraction * 2 * math.pi,
        math.pi / 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = colour,
      );
    }

    arc(-0.25, Press.blue);
    arc(0, Press.pink);

    canvas.drawCircle(centre, 13, Paint()..color = Press.paper);
    canvas.drawCircle(
      centre,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Press.ink.withValues(alpha: 0.3),
    );
  }

  @override
  bool shouldRepaint(_DiscPainter oldDelegate) => oldDelegate.turns != turns;
}
