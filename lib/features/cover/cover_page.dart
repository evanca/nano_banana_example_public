import 'package:flutter/material.dart';

import '../../state/cover_controller.dart';
import 'cover_layout.dart';
import 'widgets/cover_actions.dart';
import 'widgets/cover_masthead.dart';
import 'widgets/plate_specs.dart';
import 'widgets/proof_panel.dart';

/// The cover sheet, stacked in one column at every width.
class CoverPage extends StatelessWidget {
  const CoverPage({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // One listener at the top; everything below rebuilds together.
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => SafeArea(
          child: ListView(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CoverLayout.maxSheetWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CoverMasthead(controller: controller),
                        const SizedBox(height: 40),
                        ProofPanel(controller: controller),
                        const SizedBox(height: 32),
                        PlateSpecs(controller: controller),
                        const SizedBox(height: 32),
                        CoverActions(controller: controller),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
