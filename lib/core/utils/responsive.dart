import 'dart:math' as math;

class Responsive {
  const Responsive._();

  static double scale(double base, double shortestSide) {
    final factor = (shortestSide / 390).clamp(0.82, 1.45);
    return base * factor;
  }

  static double clamp(double value, double min, double max) {
    return math.min(math.max(value, min), max);
  }

  static int crossAxisCount(double width) {
    if (width >= 1100) return 6;
    if (width >= 720) return 5;
    return 4;
  }
}
