import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The type of neumorphic shadow to render.
enum NeuType {
  /// Raised / convex — shadows cast outward.
  flat,

  /// Pressed / concave — shadows cast inward (simulated).
  inset,
}

/// A container with neumorphic (soft-UI) shadows.
///
/// [NeuType.flat] casts outer shadows; [NeuType.inset] simulates
/// inner shadows via a gradient overlay (Flutter has no native inset BoxShadow).
class NeuContainer extends StatelessWidget {
  const NeuContainer({
    super.key,
    required this.child,
    this.type = NeuType.flat,
    this.borderRadius = 16,
    this.padding,
    this.color,
    this.width,
    this.height,
    this.offset = 6,
    this.blurRadius = 12,
    this.border,
  });

  final Widget child;
  final NeuType type;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? width;
  final double? height;
  final double offset;
  final double blurRadius;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? AppColors.neuBackground;
    final radius = BorderRadius.circular(borderRadius);
    final raisedDarkShadow = isDark
        ? Colors.black.withValues(alpha: 0.62)
        : AppColors.neuShadowDark;
    final raisedLightShadow = isDark
        ? AppColors.neuShadowLight.withValues(alpha: 0.7)
        : AppColors.neuShadowLight;

    if (type == NeuType.flat) {
      return Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: border,
          boxShadow: [
            BoxShadow(
              color: raisedDarkShadow,
              offset: Offset(offset, offset),
              blurRadius: blurRadius,
            ),
            BoxShadow(
              color: raisedLightShadow,
              offset: Offset(-offset, -offset),
              blurRadius: blurRadius,
            ),
          ],
        ),
        child: child,
      );
    }

    // Inset simulation: paint a container, then clip and overlay
    // inner shadows with gradient stops.
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: _InsetShadowPainter(
            shadowDark: isDark
                ? Colors.black.withValues(alpha: 0.70)
                : AppColors.neuShadowDark,
            shadowLight: isDark
                ? AppColors.neuShadowLight.withValues(alpha: 0.8)
                : AppColors.neuShadowLight,
            blur: blurRadius * 0.67,
          ),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

/// Paints simulated inset shadows via linear gradients on each edge.
class _InsetShadowPainter extends CustomPainter {
  _InsetShadowPainter({
    required this.shadowDark,
    required this.shadowLight,
    this.blur = 8,
  });

  final Color shadowDark;
  final Color shadowLight;
  final double blur;

  @override
  void paint(Canvas canvas, Size size) {
    // Top-left inset shadow (dark, from top-left)
    final darkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          shadowDark.withValues(alpha: 0.5),
          shadowDark.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), darkPaint);

    // Bottom-right inset shadow (light, from bottom-right)
    final lightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [
          shadowLight.withValues(alpha: 0.7),
          shadowLight.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), lightPaint);
  }

  @override
  bool shouldRepaint(covariant _InsetShadowPainter oldDelegate) {
    return oldDelegate.shadowDark != shadowDark ||
        oldDelegate.shadowLight != shadowLight ||
        oldDelegate.blur != blur;
  }
}
