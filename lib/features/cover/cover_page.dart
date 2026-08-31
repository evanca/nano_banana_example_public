import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../state/cover_controller.dart';
import '../camera/camera_page.dart';
import 'cover_layout.dart';
import 'widgets/cover_actions.dart';
import 'widgets/cover_masthead.dart';
import 'widgets/cover_top_bar.dart';
import 'widgets/plate_specs.dart';
import 'widgets/proof_panel.dart';

/// The proof sheet: specs on the left, the printed spread on the right.
class CoverPage extends StatelessWidget {
  const CoverPage({required this.controller, super.key});

  final CoverController controller;

  Future<void> _takeSelfie(BuildContext context) async {
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );
    if (bytes != null) controller.setSelfie(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => SafeArea(
          child: ListView(
            children: [
              CoverTopBar(controller: controller),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CoverLayout.maxSheetWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CoverMasthead(controller: controller),
                        const SizedBox(height: 40),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final specs = PlateSpecs(controller: controller);
                            final actions = CoverActions(
                              controller: controller,
                              onTakeSelfie: () => _takeSelfie(context),
                            );
                            final proof = ProofPanel(controller: controller);

                            if (constraints.maxWidth <
                                CoverLayout.wideBreakpoint) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  proof,
                                  const SizedBox(height: 32),
                                  specs,
                                  const SizedBox(height: 32),
                                  actions,
                                ],
                              );
                            }
                            // The controls belong to the plate, not the sheet.
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 4, child: specs),
                                const SizedBox(width: 48),
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      proof,
                                      const SizedBox(height: 28),
                                      actions,
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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
