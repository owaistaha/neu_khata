import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A soft neumorphic button that visually sinks into the surface
/// when pressed and pops back when released.
///
/// Follows classic neumorphism:
/// - **Raised** = light shadow top-left, dark shadow bottom-right
/// - **Pressed** = shadows invert, slight scale-down (0.97)
/// - Smooth 150ms animation via [AnimatedContainer] + [AnimatedScale]
///
/// Works in both light and dark mode automatically.
class NeuButton extends StatefulWidget {
  const NeuButton({
    super.key,
    this.text,
    this.icon,
    required this.onTap,
    this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.padding,
    this.color,
  }) : assert(child != null || text != null, 'Provide either child or text');

  /// Button label text. Ignored if [child] is provided.
  final String? text;

  /// Leading icon. Ignored if [child] is provided.
  final IconData? icon;

  /// Tap callback.
  final VoidCallback onTap;

  /// Custom child widget — overrides [text] and [icon].
  final Widget? child;

  /// Fixed dimensions (optional).
  final double? width;
  final double? height;

  /// Corner radius. Default 16.
  final double borderRadius;

  /// Inner padding. Defaults to symmetrical 16h × 14v.
  final EdgeInsetsGeometry? padding;

  /// Base color override. Defaults to theme-aware neumorphic base.
  final Color? color;

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  // ─── Shadow colors ──────────────────────────────────────────────
  // Light mode
  static const _lightShadowLight = Color(0xCCFFFFFF); // white @ 0.8
  static const _lightShadowDark = Color(0x26000000); // black @ 0.15
  static const _lightPressedLight = Color(0xB3FFFFFF); // white @ 0.7
  static const _lightPressedDark = Color(0x33000000); // black @ 0.2

  // Dark mode
  static const _darkShadowLight = Color(0xB31E2B22);
  static const _darkShadowDark = Color(0xB3000000); // black @ 0.7
  static const _darkPressedLight = Color(0x801E2B22);
  static const _darkPressedDark = Color(0xCC000000); // black @ 0.8

  static const _animDuration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        widget.color ??
        (isDark ? AppColors.darkSurface : AppColors.neuBackground);

    // Pick shadow colors based on theme + state
    final Color shadowTopLeft;
    final Color shadowBottomRight;

    if (_isPressed) {
      // Pressed → shadows invert
      shadowTopLeft = isDark ? _darkPressedDark : _lightPressedDark;
      shadowBottomRight = isDark ? _darkPressedLight : _lightPressedLight;
    } else {
      // Raised → light top-left, dark bottom-right
      shadowTopLeft = isDark ? _darkShadowLight : _lightShadowLight;
      shadowBottomRight = isDark ? _darkShadowDark : _lightShadowDark;
    }

    final offset = _isPressed ? 2.0 : 5.0;
    final blur = _isPressed ? 6.0 : 12.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: _animDuration,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: _animDuration,
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: shadowTopLeft,
                offset: Offset(-offset, -offset),
                blurRadius: blur,
              ),
              BoxShadow(
                color: shadowBottomRight,
                offset: Offset(offset, offset),
                blurRadius: blur,
              ),
            ],
          ),
          child: _buildContent(isDark),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    // If custom child is provided, use it directly
    if (widget.child != null) return widget.child!;

    // Otherwise build from text + optional icon
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    final label = Text(
      widget.text!,
      style: AppTextStyles.labelLarge.copyWith(color: textColor),
    );

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          label,
        ],
      );
    }

    return Center(child: label);
  }
}
