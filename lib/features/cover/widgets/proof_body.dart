import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';

/// What sits on the plate.
class ProofBody extends StatelessWidget {
  const ProofBody({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isBusy) {
      return const _Placeholder('GENERATING…');
    }
    final art = controller.draft?.image ?? controller.selfie;
    if (art == null) {
      return const _Placeholder('AWAITING SELFIE');
    }
    // Contain, never cover: a portrait selfie would be cropped in half.
    return ColoredBox(
      color: Colors.black12,
      child: Image.memory(art, fit: BoxFit.contain),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(child: Text(label, style: const TextStyle(fontSize: 12))),
    );
  }
}
