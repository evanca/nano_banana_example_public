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
    final art = controller.draft?.image;
    if (art == null) {
      return const _Placeholder('NOTHING PRESSED YET');
    }
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
