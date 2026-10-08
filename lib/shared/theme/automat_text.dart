import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'automat_colors.dart';

/// Type scale from the design system. Letter spacing is specified in em,
/// so it is multiplied by the font size here.
abstract final class AutomatText {
  static const _tabular = [FontFeature.tabularFigures()];

  static TextStyle _grotesk(double size, FontWeight weight, double line, double em) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        height: line / size,
        letterSpacing: em * size,
        color: AutomatColors.paper,
        fontFeatures: _tabular,
      );

  static TextStyle _geist(double size, double line, double em) => GoogleFonts.geist(
    fontSize: size,
    fontWeight: FontWeight.w400,
    height: line / size,
    letterSpacing: em * size,
    color: AutomatColors.paper,
  );

  static TextStyle _mono(double size, double line, double em) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: FontWeight.w500,
    height: line / size,
    letterSpacing: em * size,
    color: AutomatColors.halftone,
    fontFeatures: _tabular,
  );

  static final headlineXl = _grotesk(56, FontWeight.w700, 60, -0.03);
  static final headlineXlMobile = _grotesk(36, FontWeight.w700, 40, -0.02);
  static final headlineLg = _grotesk(36, FontWeight.w600, 42, -0.02);
  static final headlineLgMobile = _grotesk(28, FontWeight.w600, 34, -0.01);
  static final headlineMd = _grotesk(24, FontWeight.w600, 30, -0.01);

  /// Oversized countdown digits in the viewfinder OSD.
  static final countdown = _grotesk(
    180,
    FontWeight.w700,
    180,
    -0.04,
  ).copyWith(color: AutomatColors.acid);

  static final bodyLg = _geist(18, 26, -0.01);
  static final bodyMd = _geist(15, 22, 0);
  static final bodySm = _geist(13, 18, 0);

  static final labelLg = _mono(14, 18, 0.04);
  static final labelMd = _mono(12, 16, 0.06);
  static final labelSm = _mono(10, 14, 0.08);
}
