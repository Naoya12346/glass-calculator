import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderRadius = AppSpacing.cardRadius,
    this.blur = 18,
    this.opacity = 0.10,
    this.borderOpacity = 0.30,
    this.showHighlight = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final bool showHighlight;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    const fill = Colors.white;
    final shadow = isDark ? Colors.black : AppColorsShadow.light;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  fill.withValues(alpha: opacity + (showHighlight ? 0.06 : 0)),
                  fill.withValues(alpha: opacity * 0.55),
                ],
              ),
              border: Border.all(
                color: fill.withValues(alpha: borderOpacity),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: shadow.withValues(alpha: isDark ? 0.34 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppColorsShadow {
  const AppColorsShadow._();

  static const Color light = Color(0xFF2A3A66);
}
