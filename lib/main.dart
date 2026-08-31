import 'package:flutter/material.dart';

import 'features/cover/cover_page.dart';

void main() {
  runApp(const CdCoverApp());
}

/// The CD cover press, as a screen and nothing else.
///
/// No state, no service, no model. Every value is written into the widget
/// that shows it, and the buttons do nothing.
class CdCoverApp extends StatelessWidget {
  const CdCoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Nano Banana CD Cover',
      debugShowCheckedModeBanner: false,
      home: CoverPage(),
    );
  }
}
