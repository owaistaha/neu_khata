import 'package:flutter/material.dart';
import 'app_colors.dart';

class NeuShadows {
  static List<BoxShadow> raised(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.65)
            : const Color(0x26000000),
        offset: const Offset(6, 6),
        blurRadius: 14,
      ),
      BoxShadow(
        color: isDark
            ? AppColors.neuShadowLight.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9),
        offset: const Offset(-6, -6),
        blurRadius: 14,
      ),
    ];
  }

  static List<BoxShadow> pressed(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.8)
            : const Color(0x33000000),
        offset: const Offset(-3, -3),
        blurRadius: 8,
      ),
      BoxShadow(
        color: isDark
            ? AppColors.neuShadowLight.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.7),
        offset: const Offset(3, 3),
        blurRadius: 8,
      ),
    ];
  }
}
