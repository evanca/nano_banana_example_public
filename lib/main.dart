import 'package:flutter/material.dart';

import 'features/cover/cover_page.dart';
import 'state/cover_controller.dart';

void main() {
  runApp(CdCoverApp(controller: CoverController()));
}

/// The CD cover press. The model is still a stub.
///
/// The whole sheet is wired; only the round-trip is missing.
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
