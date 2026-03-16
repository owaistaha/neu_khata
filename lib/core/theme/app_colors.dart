import 'package:flutter/material.dart';

/// Neumorphic design palette for Khata Digital.
///
/// Derived from the HTML design references with neumorphic
/// shadow pairs and semantic transaction colors.
abstract final class AppColors {
  // ─── Brand ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF21C45D);
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color primaryDark = Color(0xFF16A34A);

  // ─── Accent (Indigo — onboarding, reminders) ─────────────────────
  static const Color accent = Color(0xFF6366F1);
  static const Color accentDark = Color(0xFF4F46E5);

  // ─── Semantic ─────────────────────────────────────────────────────
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDark = Color(0xFFDC2626);
  static const Color success = Color(0xFF21C45D);
  static const Color warning = Color(0xFFF59E0B);

  // ─── Neumorphic Surfaces ──────────────────────────────────────────
  static const Color neuBackground = Color(0xFFE9EEF4);
  static const Color neuBackgroundAlt = Color(0xFFE9EEF4);
  static const Color neuShadowDark = Color(0xFFA3B1C6);
  static const Color neuShadowLight = Color(0xFFFFFFFF);
  static const Color neuShadowDarkAlt = Color(0xFFA3B1C6);
  static const Color neuShadowDarkAlt2 = Color(0xFFB6C2D4);

  // ─── Text ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Dark Mode ─────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF122017);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ─── Miscellaneous ────────────────────────────────────────────────
  static const Color cardWhite = Color(0xFFE9EEF4);
  static const Color divider = Color(0xFFD2DBE8);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
}
