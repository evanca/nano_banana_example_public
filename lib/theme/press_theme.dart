import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the proof-sheet look.
abstract final class Press {
  static const Color ink = Color(0xFF101C33);
  static const Color inkDeep = Color(0xFF0B1426);
  static const Color paper = Color(0xFFE4E7EA);
  static const Color paperLight = Color(0xFFF2F4FF);
  static const Color rule = Color(0xFFCCD3DA);
  static const Color blue = Color(0xFF2B3DF5);
  static const Color pink = Color(0xFFFF3D7F);

  static Color inkAt(double opacity) => ink.withValues(alpha: opacity);

  /// Monospace, wide-tracked — every label and spec value.
  static TextStyle mono({
    double size = 11,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double tracking = 0.16,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        color: color ?? ink,
        fontWeight: weight,
        letterSpacing: size * tracking,
        height: 1.4,
      );

  /// Archivo Black, tight — headlines only.
  static TextStyle display(double size) => GoogleFonts.archivoBlack(
        fontSize: size,
        color: ink,
        letterSpacing: size * -0.035,
        height: 0.94,
      );

  static TextStyle body({double size = 15, Color? color}) => GoogleFonts.archivo(
        fontSize: size,
        color: color ?? inkAt(0.75),
        height: 1.5,
      );

  /// The sheet's ground.
  static Decoration get sheet => const BoxDecoration(color: paper);
}

/// Draws the 48px graph-paper grid behind the sheet.
class GridPainter extends CustomPainter {
  const GridPainter();

  static const double cell = 48;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Press.ink.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
