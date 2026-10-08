import 'dart:typed_data';

/// Mechanical relay sound design. Every actuation clicks.
abstract interface class BoothSound {
  /// Short relay click for toggles and selectors.
  void click();

  /// Countdown tick.
  void tick();

  /// Shutter clack plus flash capacitor discharge.
  void shutter();

  /// Motorised strip dispenser.
  void dispense();
}

/// Hands a finished file to the viewer.
abstract interface class StripSaver {
  void save(Uint8List bytes, {required String fileName, required String mimeType});
}

class SilentBoothSound implements BoothSound {
  const SilentBoothSound();

  @override
  void click() {}

  @override
  void tick() {}

  @override
  void shutter() {}

  @override
  void dispense() {}
}
