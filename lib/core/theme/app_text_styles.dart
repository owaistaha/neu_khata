import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for Khata Digital — Inter only,
/// matching the HTML design references.
abstract final class AppTextStyles {
  // ─── Display ──────────────────────────────────────────────────────
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25,
  );
  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 45, fontWeight: FontWeight.w400,
  );
  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 36, fontWeight: FontWeight.w400,
  );

  // ─── Headline ─────────────────────────────────────────────────────
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w700,
  );
  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700,
  );
  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700,
  );

  // ─── Title ────────────────────────────────────────────────────────
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w700,
  );
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15,
  );
  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
  );

  // ─── Body ─────────────────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5,
  );
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4,
  );

  // ─── Label ────────────────────────────────────────────────────────
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
  );
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );

  // ─── Neumorphic-specific helpers ──────────────────────────────────
  static TextStyle amountXL = GoogleFonts.inter(
    fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1,
  );
  static TextStyle amountLarge = GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w700,
  );
  static TextStyle amountMedium = GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700,
  );
  static TextStyle amountSmall = GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w700,
  );
  static TextStyle badge = GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
  );
  static TextStyle trackingWide = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    letterSpacing: 2,
  );
}
