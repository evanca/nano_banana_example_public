import 'package:flutter/material.dart';

import 'cover_layout.dart';
import 'widgets/cover_actions.dart';
import 'widgets/cover_masthead.dart';
import 'widgets/plate_specs.dart';
import 'widgets/proof_panel.dart';

/// The cover sheet, stacked in one column at every width.
class CoverPage extends StatelessWidget {
  const CoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: CoverLayout.maxSheetWidth,
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(28, 28, 28, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CoverMasthead(),
                      SizedBox(height: 40),
                      ProofPanel(),
                      SizedBox(height: 32),
                      PlateSpecs(),
                      SizedBox(height: 32),
                      CoverActions(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
