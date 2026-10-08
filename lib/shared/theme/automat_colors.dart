import 'package:flutter/painting.dart';

/// Functional palette of the Berlin Fotoautomat design system.
abstract final class AutomatColors {
  /// Cast metal base: outermost machine housing.
  static const chassis = Color(0xFF121316);

  /// Machined panels fastened onto the chassis.
  static const panel = Color(0xFF1A1C20);
  static const panelRaised = Color(0xFF25282E);
  static const panelBorder = Color(0xFF2D3139);
  static const toggleBorder = Color(0xFF33373E);

  /// Countersunk optics and viewfinder apertures.
  static const recessed = Color(0xFF090A0B);
  static const inputField = Color(0xFF0E0F11);
  static const inputBorder = Color(0xFF2A2D35);

  /// High-voltage indicators and primary actuation.
  static const acid = Color(0xFFE5FF44);

  /// Analog bulb alerts, tally lights, heat warnings.
  static const amber = Color(0xFFFF4400);

  /// Photochemical paper and primary high-contrast type.
  static const paper = Color(0xFFF3F2EE);

  /// Telemetry and peripheral status readings.
  static const halftone = Color(0xFF8A8D93);

  /// Inert LED.
  static const slate = Color(0xFF494D55);

  static const reticle = Color(0x66F3F2EE);
  static const reticleFaint = Color(0x26F3F2EE);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  /// Hard zero-blur projection for physical media sitting on the chassis.
  static const mediaShadow = [BoxShadow(color: Color(0xE6000000), offset: Offset(4, 4))];
}
