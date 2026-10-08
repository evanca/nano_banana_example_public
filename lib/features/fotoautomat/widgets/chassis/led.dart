import 'package:flutter/widgets.dart';

import '../../../../shared/theme/automat_colors.dart';
import 'blink.dart';

/// Indicator lamp with a crisp, narrow-radius light field.
class Led extends StatelessWidget {
  const Led({
    super.key,
    required this.on,
    this.color = AutomatColors.acid,
    this.size = 8,
    this.blink = false,
    this.round = false,
  });

  final bool on;
  final Color color;
  final double size;
  final bool blink;

  /// Tally lights are round bulbs; everything else is a square diode.
  final bool round;

  @override
  Widget build(BuildContext context) {
    final lamp = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: on ? color : AutomatColors.slate,
        shape: round ? BoxShape.circle : BoxShape.rectangle,
        boxShadow: on
            ? [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: size * 0.75)]
            : null,
      ),
    );
    return on && blink ? Blink(child: lamp) : lamp;
  }
}
