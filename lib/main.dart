import 'package:flutter/material.dart';

import 'features/cover/cover_page.dart';
import 'state/cover_controller.dart';

void main() {
  runApp(CdCoverApp(controller: CoverController()));
}

/// The CD cover press, with state behind it.
///
/// One controller owns the run; the sheet listens. No photo and no model
/// yet — the service returns a bundled placeholder.
class CdCoverApp extends StatelessWidget {
  const CdCoverApp({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nano Banana CD Cover',
      debugShowCheckedModeBanner: false,
      home: CoverPage(controller: controller),
    );
  }
}
