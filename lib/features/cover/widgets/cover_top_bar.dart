import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import '../../../theme/press_theme.dart';
import 'status_dot.dart';

/// Press masthead strip: identity left, plate specs right.
class CoverTopBar extends StatelessWidget {
  const CoverTopBar({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.draft?.pixelSize;
    // Em dashes until a plate exists — never claim a size we have not made.
    final dimensions = size == null
        ? '— × — PX'
        : '${size.width.toInt()} × ${size.height.toInt()} PX';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Press.inkAt(0.18))),
      ),
      child: Row(
        children: [
          StatusDot(halted: controller.failedStage != null),
          const SizedBox(width: 10),
          Text('Nano Banana', style: Press.mono(size: 11)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '/ CD Cover Press',
              overflow: TextOverflow.ellipsis,
              style: Press.mono(size: 11, color: Press.inkAt(0.42)),
            ),
          ),
          const Spacer(),
          DefaultTextStyle(
            style: Press.mono(size: 11, color: Press.inkAt(0.42)),
            child: Row(
              children: [
                Text(dimensions),
                const SizedBox(width: 24),
                const Text('300 DPI'),
                const SizedBox(width: 24),
                Text('V2.4', style: Press.mono(size: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
