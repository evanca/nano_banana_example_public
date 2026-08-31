import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'proof_body.dart';

/// The plate the artwork sits on.
class ProofPanel extends StatelessWidget {
  const ProofPanel({required this.controller, super.key});

  final CoverController controller;

  static const double _placeholderRatio = 2;

  @override
  Widget build(BuildContext context) {
    final size = controller.draft?.pixelSize;
    final ratio = size != null && size.height > 0
        ? size.width / size.height
        : _placeholderRatio;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black45),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AspectRatio(
          aspectRatio: ratio,
          child: ProofBody(controller: controller),
        ),
      ),
    );
  }
}
