import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Public reCAPTCHA v3 **site** key, passed per build with
/// `--dart-define=RECAPTCHA_SITE_KEY=...`. The secret stays in the console.
const String _siteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

/// Fixed App Check debug token. Without one, every browser mints its own.
const String _debugToken = String.fromEnvironment('APPCHECK_DEBUG_TOKEN');

/// Turns on App Check, which Firebase AI Logic enforces.
///
/// The token must go to [WebDebugProvider], not the global — the plugin
/// overwrites that with `true` while resolving the provider.
Future<void> activateAppCheck() async {
  if (kReleaseMode && _siteKey.isEmpty) {
    throw StateError(
      'Release builds need a reCAPTCHA v3 site key. Create one in the Firebase '
      'console under App Check, then build with '
      '--dart-define=RECAPTCHA_SITE_KEY=...',
    );
  }
  await FirebaseAppCheck.instance.activate(
    providerWeb: kReleaseMode
        ? ReCaptchaV3Provider(_siteKey)
        : WebDebugProvider(
            debugToken: _debugToken.isEmpty ? null : _debugToken,
          ),
  );
}
