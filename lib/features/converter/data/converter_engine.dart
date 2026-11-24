import '../data/converter_catalog.dart';

class ConverterEngine {
  const ConverterEngine._();

  static double convert({
    required double value,
    required UnitCategory category,
    required String fromId,
    required String toId,
  }) {
    if (fromId == toId) return value;

    if (category.id == 'temperature') {
      final celsius = _toCelsius(value, fromId);
      return _fromCelsius(celsius, toId);
    }

    final from = category.unit(fromId);
    final to = category.unit(toId);
    final base = value * from.factor;
    return base / to.factor;
  }

  static double _toCelsius(double value, String unit) {
    return switch (unit) {
      'c' => value,
      'f' => (value - 32) * 5 / 9,
      'k' => value - 273.15,
      _ => value,
    };
  }

  static double _fromCelsius(double value, String unit) {
    return switch (unit) {
      'c' => value,
      'f' => value * 9 / 5 + 32,
      'k' => value + 273.15,
      _ => value,
    };
  }
}
