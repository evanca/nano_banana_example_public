import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import '../../../theme/press_theme.dart';

/// One-line press state, when no run is in flight or halted.
class PressStatus extends StatelessWidget {
  const PressStatus({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final (label, colour) = switch (controller.status) {
      CoverStatus.generating => ('On press', Press.blue),
      CoverStatus.ready => ('Booth ready', Press.blue),
      CoverStatus.error => ('Plate error', Press.pink),
      CoverStatus.idle when controller.hasSelfie =>
        ('Ready to print', Press.blue),
      CoverStatus.idle => ('Awaiting selfie', Press.inkAt(0.42)),
    };
    return Row(
      children: [
        Container(width: 8, height: 8, color: colour),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: Press.mono(size: 11, color: Press.inkAt(0.6), tracking: 0.22),
        ),
      ],
    );
  }
}
