import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'automat_colors.dart';

/// Dark is the only mode: the interior of a darkened booth enclosure.
abstract final class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AutomatColors.chassis,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textTheme: GoogleFonts.geistTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF121316),
      onSurface: Color(0xFFE3E2E6),
      onSurfaceVariant: Color(0xFFC7C9AE),
      primary: AutomatColors.acid,
      onPrimary: AutomatColors.chassis,
      secondary: AutomatColors.amber,
      onSecondary: Color(0xFF601400),
      tertiary: AutomatColors.paper,
      onTertiary: Color(0xFF30312E),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      outline: Color(0xFF90937A),
      outlineVariant: Color(0xFF464834),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: const BoxDecoration(color: AutomatColors.paper, borderRadius: BorderRadius.zero),
      textStyle: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        color: AutomatColors.chassis,
        letterSpacing: 0.6,
      ),
      waitDuration: const Duration(milliseconds: 300),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(),
      backgroundColor: AutomatColors.chassis,
    ),
  );
}
