import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:glass_calculator/features/calculator/domain/calculator_exception.dart';
import 'package:glass_calculator/features/calculator/domain/evaluator.dart';

void main() {
  group('ExpressionEvaluator', () {
    test('adds', () {
      expect(ExpressionEvaluator.evaluate('2+3'), 5);
    });

    test('subtracts', () {
      expect(ExpressionEvaluator.evaluate('9-4'), 5);
    });

    test('multiplies', () {
      expect(ExpressionEvaluator.evaluate('6*7'), 42);
    });

    test('divides', () {
      expect(ExpressionEvaluator.evaluate('20/4'), 5);
    });

    test('respects operator precedence', () {
      expect(ExpressionEvaluator.evaluate('2+3*4'), 14);
    });

    test('respects parentheses', () {
      expect(ExpressionEvaluator.evaluate('(2+3)*4'), 20);
    });

    test('handles chained operations', () {
      expect(ExpressionEvaluator.evaluate('10-2+3*2'), 14);
    });

    test('handles decimals', () {
      expect(ExpressionEvaluator.evaluate('1.5+2.25'), 3.75);
    });

    test('handles leading decimal', () {
      expect(ExpressionEvaluator.evaluate('.5+1'), 1.5);
    });

    test('handles unary minus', () {
      expect(ExpressionEvaluator.evaluate('-2+3'), 1);
    });

    test('exponent binds before unary minus', () {
      expect(ExpressionEvaluator.evaluate('-2^2'), -4);
    });

    test('handles negative exponent', () {
      expect(ExpressionEvaluator.evaluate('2^-3'), closeTo(0.125, 1e-12));
    });

    test('is right associative for powers', () {
      expect(ExpressionEvaluator.evaluate('2^3^2'), 512);
    });

    test('supports implicit multiplication', () {
      expect(ExpressionEvaluator.evaluate('2(3+4)'), 14);
    });

    test('supports unicode pi', () {
      expect(
        ExpressionEvaluator.evaluate('π'),
        closeTo(math.pi, 1e-12),
      );
    });

    test('supports pi constant', () {
      expect(
        ExpressionEvaluator.evaluate('2*pi'),
        closeTo(2 * math.pi, 1e-12),
      );
    });

    test('supports e constant', () {
      expect(ExpressionEvaluator.evaluate('e^0'), 1);
    });

    test('computes sine in degrees', () {
      expect(ExpressionEvaluator.evaluate('sin(30)'), closeTo(0.5, 1e-12));
    });

    test('computes sine in radians', () {
      expect(
        ExpressionEvaluator.evaluate('sin(pi/2)', angleMode: AngleMode.radians),
        closeTo(1, 1e-12),
      );
    });

    test('computes cosine', () {
      expect(ExpressionEvaluator.evaluate('cos(60)'), closeTo(0.5, 1e-12));
    });

    test('computes tangent', () {
      expect(ExpressionEvaluator.evaluate('tan(45)'), closeTo(1, 1e-12));
    });

    test('computes inverse sine', () {
      expect(ExpressionEvaluator.evaluate('asin(1)'), closeTo(90, 1e-12));
    });

    test('computes base 10 logarithm', () {
      expect(ExpressionEvaluator.evaluate('log(100)'), closeTo(2, 1e-12));
    });

    test('computes natural logarithm', () {
      expect(ExpressionEvaluator.evaluate('ln(e)'), closeTo(1, 1e-12));
    });

    test('computes square root', () {
      expect(ExpressionEvaluator.evaluate('√16'), 4);
    });

    test('computes powers', () {
      expect(ExpressionEvaluator.evaluate('2^10'), 1024);
    });

    test('computes factorial', () {
      expect(ExpressionEvaluator.evaluate('5!'), 120);
    });

    test('computes zero factorial', () {
      expect(ExpressionEvaluator.evaluate('0!'), 1);
    });

    test('computes percent as fraction', () {
      expect(ExpressionEvaluator.evaluate('50%'), 0.5);
    });

    test('applies percent relative to an addition base', () {
      expect(ExpressionEvaluator.evaluate('200+10%'), 220);
    });

    test('applies percent relative to a subtraction base', () {
      expect(ExpressionEvaluator.evaluate('200-10%'), 180);
    });

    test('handles percent multiplied by a value', () {
      expect(ExpressionEvaluator.evaluate('10%*200'), 20);
    });

    test('supports nested functions', () {
      expect(
        ExpressionEvaluator.evaluate('sqrt(9)+sin(30)'),
        closeTo(3.5, 1e-12),
      );
    });

    test('supports hyperbolic functions', () {
      expect(ExpressionEvaluator.evaluate('sinh(0)'), 0);
    });

    test('supports absolute value', () {
      expect(ExpressionEvaluator.evaluate('abs(-5)'), 5);
    });

    test('throws on division by zero', () {
      expect(
        () => ExpressionEvaluator.evaluate('5/0'),
        throwsA(
          isA<CalculatorException>().having(
            (error) => error.error,
            'error',
            CalculatorError.divisionByZero,
          ),
        ),
      );
    });

    test('throws on negative square root', () {
      expect(
        () => ExpressionEvaluator.evaluate('sqrt(-1)'),
        throwsA(
          isA<CalculatorException>().having(
            (error) => error.error,
            'error',
            CalculatorError.invalidDomain,
          ),
        ),
      );
    });

    test('throws on invalid natural log', () {
      expect(
        () => ExpressionEvaluator.evaluate('ln(0)'),
        throwsA(isA<CalculatorException>()),
      );
    });

    test('throws on invalid factorial', () {
      expect(
        () => ExpressionEvaluator.evaluate('3.5!'),
        throwsA(isA<CalculatorException>()),
      );
    });

    test('throws on unmatched parenthesis', () {
      expect(
        () => ExpressionEvaluator.evaluate('(2+3'),
        throwsA(isA<CalculatorException>()),
      );
    });

    test('throws on overflow', () {
      expect(
        () => ExpressionEvaluator.evaluate('9^400'),
        throwsA(
          isA<CalculatorException>().having(
            (error) => error.error,
            'error',
            CalculatorError.overflow,
          ),
        ),
      );
    });

    test('preview is null while typing', () {
      expect(ExpressionEvaluator.preview('2+'), isNull);
    });

    test('preview returns a value for a complete expression', () {
      expect(ExpressionEvaluator.preview('2+3')?.value, 5);
    });
  });
}
