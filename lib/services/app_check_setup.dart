import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Fixed App Check debug token, passed with
/// `--dart-define-from-file=app_check.local.json` (gitignored).
/// Without one, each browser profile mints its own and logs it to the console.
const String _debugToken = String.fromEnvironment('APPCHECK_DEBUG_TOKEN');

/// Turns on App Check with the web debug provider.
///
/// The token must go to [WebDebugProvider], not the JS global — the plugin
/// overwrites that while resolving the provider.
Future<void> activateAppCheck() async {
  await FirebaseAppCheck.instance.activate(
    providerWeb: WebDebugProvider(debugToken: _debugToken.isEmpty ? null : _debugToken),
  );
  if (kDebugMode) await _logTokenStatus();
}

Future<void> _logTokenStatus() async {
  if (_debugToken.isNotEmpty) debugPrint('App Check debug token: $_debugToken');
  try {
    await FirebaseAppCheck.instance.getToken();
    debugPrint('App Check: token accepted');
  } catch (e) {
    debugPrint('App Check: token rejected — $e');
  }
}
