import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'neumorphic_container.dart';

/// A neumorphic inset progress bar with animated fill.
class NeuProgressBar extends StatelessWidget {
  const NeuProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.fillColor,
    this.trackPadding = 4,
  });

  /// Value between 0.0 and 1.0.
  final double progress;
  final double height;
  final Color? fillColor;
  final double trackPadding;

  @override
  Widget build(BuildContext context) {
    final fill = fillColor ?? AppColors.primary;

    return NeuContainer(
      type: NeuType.inset,
      borderRadius: height / 2,
      height: height,
      padding: EdgeInsets.all(trackPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: constraints.maxWidth * progress.clamp(0.0, 1.0),
              height: height - trackPadding * 2,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(
                  (height - trackPadding * 2) / 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
