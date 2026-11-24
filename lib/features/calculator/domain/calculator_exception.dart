enum CalculatorError {
  syntax,
  divisionByZero,
  overflow,
  invalidDomain,
  unknownToken,
}

class CalculatorException implements Exception {
  const CalculatorException(this.error, this.message);

  final CalculatorError error;
  final String message;

  @override
  String toString() => message;
}
