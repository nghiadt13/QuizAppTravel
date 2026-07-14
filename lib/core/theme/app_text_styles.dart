import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Montserrat - Headings
  static TextStyle displayLarge = GoogleFonts.montserrat(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
  );

  static TextStyle displayLargeMobile = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
  );

  static TextStyle headlineMedium = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headlineSmall = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Inter - Body & Labels
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
