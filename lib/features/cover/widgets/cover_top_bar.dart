import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black26)),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 11),
        child: Row(
          children: [
            StatusDot(halted: controller.failedStage != null),
            const SizedBox(width: 10),
            const Text('Nano Banana'),
            const SizedBox(width: 8),
            const Flexible(
              child: Text('/ CD Cover Press', overflow: TextOverflow.ellipsis),
            ),
            const Spacer(),
            Text(dimensions),
            const SizedBox(width: 24),
            const Text('300 DPI'),
            const SizedBox(width: 24),
            const Text('V2.4'),
          ],
        ),
      ),
    );
  }
}
