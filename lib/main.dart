import 'app/bootstrap.dart';

// Before the first run, add your own Firebase setup:
//
// 1. Generate `lib/firebase_options.dart` (not committed) for your project:
//      flutterfire configure --project=<your-firebase-project-id>
//    The project needs the Blaze plan (image models have no free tier) and
//    Firebase AI Logic enabled with the Gemini Developer API.
// 2. App Check is enforced, so Gemini calls fail without a debug token.
//    Register a web app debug token in Firebase console > App Check >
//    Manage debug tokens, then copy `app_check.local.example.json` to
//    `app_check.local.json` (not committed) and replace the placeholder.
// 3. Run with the token:
//      flutter run -d chrome --dart-define-from-file=app_check.local.json
Future<void> main() => bootstrap();
