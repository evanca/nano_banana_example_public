import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';

/// One-line press state, when no run is in flight or halted.
class PressStatus extends StatelessWidget {
  const PressStatus({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final label = switch (controller.status) {
      CoverStatus.generating => 'On press',
      CoverStatus.ready => 'Booth ready',
      CoverStatus.error => 'Plate error',
      CoverStatus.idle when controller.hasSelfie => 'Ready to print',
      CoverStatus.idle => 'Awaiting selfie',
    };
    return Row(
      children: [
        Container(width: 8, height: 8, color: Colors.black),
        const SizedBox(width: 10),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
