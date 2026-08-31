import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'features/cover/cover_page.dart';
import 'services/app_check_setup.dart';
import 'state/cover_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await activateAppCheck();
  runApp(CdCoverApp(controller: CoverController()));
}

/// The press sheet with no theme, fonts or animations.
///
/// Every measurement matches the finished app; nothing else does.
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
