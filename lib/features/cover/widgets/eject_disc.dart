import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// The finished disc. Tap it to load it back in.
class EjectDisc extends StatefulWidget {
  const EjectDisc({
    required this.ejected,
    required this.onTap,
    required this.left,
    required this.reserve,
    this.size = 210,
    super.key,
  });

  final bool ejected;
  final VoidCallback onTap;
  final double size;

  /// Height of the strip reserved below the plate.
  final double reserve;

  /// From the plate's left edge. `Align` would drift as the disc grows.
  final double left;

  /// Fraction left protruding when ejected.
  static const double protrusion = 0.48;

  /// Disc diameter as a fraction of the plate width.
  static const double plateFraction = 0.42;

  /// Where the centre sits across the plate.
  static const double centreFraction = 0.725;

  @override
  State<EjectDisc> createState() => _EjectDiscState();
}

class _EjectDiscState extends State<EjectDisc> with TickerProviderStateMixin {
  /// Eject is slow and eased-out, retract quicker and eased-in.
  late final _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    reverseDuration: const Duration(milliseconds: 550),
  );

  late final _travel = CurvedAnimation(
    parent: _slide,
    curve: const Cubic(0.22, 0.9, 0.25, 1),
    reverseCurve: const Cubic(0.5, 0, 0.7, 0.3),
  );

  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();

  @override
  void initState() {
    super.initState();
    if (widget.ejected) _slide.forward();
  }

  @override
  void didUpdateWidget(EjectDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ejected != oldWidget.ejected) {
      widget.ejected ? _slide.forward() : _slide.reverse();
    }
  }

  @override
  void dispose() {
    _travel.dispose();
    _slide.dispose();
    _spin.dispose();
    super.dispose();
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _travel,
      builder: (context, child) {
        // Measured from the bottom of the reserved strip.
        final bottom = _lerp(
          widget.reserve + 0.01 * widget.size,
          0,
          _travel.value,
        );
        return Positioned(left: widget.left, bottom: bottom, child: child!);
      },
      child: SizedBox.square(
        dimension: widget.size,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: RotationTransition(
              turns: _spin,
              child: const _DiscFace(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Iridescent CD face.
class _DiscFace extends StatelessWidget {
  const _DiscFace();

  static const List<Color> _sheen = [
    Color(0xFFC9D2F5),
    Color(0xFFF4A6C8),
    Color(0xFFBFE6E0),
    Color(0xFFE8E2B8),
    Color(0xFFC9D2F5),
    Color(0xFFA8B4EE),
    Color(0xFFF0B7D3),
    Color(0xFFC9D2F5),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(colors: _sheen),
        boxShadow: [
          BoxShadow(
            color: Press.ink.withValues(alpha: 0.6),
            blurRadius: 26,
            spreadRadius: -10,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final d = constraints.maxWidth;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: d * 0.48,
                height: d * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Press.paper.withValues(alpha: 0.9),
                  border: Border.all(color: Press.inkAt(0.18)),
                ),
              ),
              Container(
                width: d * 0.18,
                height: d * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Press.paper,
                  border: Border.all(color: Press.inkAt(0.3)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
