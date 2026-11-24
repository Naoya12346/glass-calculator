import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../constants/app_colors.dart';
import '../constants/app_durations.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.orb,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amoled = isDark && Theme.of(context).colorScheme.surface == Colors.black;
    const colors = <Color>[
      AppColors.azure,
      AppColors.violet,
      AppColors.mint,
    ];

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final t = _controller.value * math.pi * 2;
              final orbs = <Widget>[
                _orb(
                  color: colors[0],
                  size: math.min(w, h) * 0.72,
                  x: w * (0.10 + 0.08 * math.sin(t)),
                  y: h * (0.05 + 0.08 * math.cos(t * 0.8)),
                  alpha: amoled ? 0.16 : 0.34,
                ),
                _orb(
                  color: colors[1],
                  size: math.min(w, h) * 0.62,
                  x: w * (0.58 + 0.10 * math.cos(t * 0.7)),
                  y: h * (0.30 + 0.10 * math.sin(t * 1.1)),
                  alpha: amoled ? 0.14 : 0.30,
                ),
                _orb(
                  color: colors[2],
                  size: math.min(w, h) * 0.56,
                  x: w * (0.28 + 0.12 * math.sin(t * 1.3)),
                  y: h * (0.62 + 0.09 * math.cos(t * 0.9)),
                  alpha: amoled ? 0.12 : 0.26,
                ),
              ];

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: amoled
                            ? <Color>[Colors.black, const Color(0xFF050505)]
                            : isDark
                                ? <Color>[
                                    AppColors.darkCanvasTop,
                                    AppColors.darkCanvasBottom,
                                  ]
                                : <Color>[
                                    AppColors.lightCanvasTop,
                                    AppColors.lightCanvasBottom,
                                  ],
                      ),
                    ),
                  ),
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
                    child: Stack(children: orbs),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _orb({
    required Color color,
    required double size,
    required double x,
    required double y,
    required double alpha,
  }) {
    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
