import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../features/fotoautomat/fotoautomat.dart';
import '../features/fotoautomat/services/web/web_booth_sound.dart';
import '../features/fotoautomat/services/web/web_strip_saver.dart';
import '../firebase_options.dart';
import '../services/app_check_setup.dart';
import 'app.dart';

/// Startup: Firebase → App Check (enforced, Gemini calls fail without it)
/// → wire the booth's hardware → run app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await activateAppCheck();

  runApp(
    App(
      createBooth: () => BoothCubit(
        camera: DeviceBoothCamera(),
        developer: GeminiStripDeveloper(),
        sound: WebBoothSound(),
        saver: const WebStripSaver(),
      ),
    ),
  );
}
