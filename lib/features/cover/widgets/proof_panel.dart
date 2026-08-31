import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'proof_body.dart';
import 'proof_frame.dart';

/// The plate and its furniture. No eject disc — that is pure animation.
class ProofPanel extends StatelessWidget {
  const ProofPanel({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black45),
      ),
      child: ProofFrame(
        pixelSize: controller.draft?.pixelSize,
        caption: controller.failedStage != null
            ? 'Spread — not imposed'
            : 'Spread — back / front',
        rightNote: 'CMYK · uncoated',
        child: ProofBody(controller: controller),
      ),
    );
  }
}
