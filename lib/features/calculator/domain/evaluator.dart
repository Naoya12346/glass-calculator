import 'dart:math' as math;

import 'calculator_exception.dart';
import 'token.dart';
import 'tokenizer.dart';

enum AngleMode { degrees, radians }

class EvaluationValue {
  const EvaluationValue(this.value);

  final double value;
}

class ExpressionEvaluator {
  const ExpressionEvaluator._();

  static double evaluate(
    String expression, {
    AngleMode angleMode = AngleMode.degrees,
  }) {
    final tokens = Tokenizer.tokenize(expression);
    if (tokens.isEmpty) {
      throw const CalculatorException(CalculatorError.syntax, 'Enter an expression.');
    }

    final values = <double>[];
    final operators = <Token>[];
    var expectOperand = true;

    for (final token in tokens) {
      switch (token.type) {
        case TokenType.number:
          if (!expectOperand) {
            throw const CalculatorException(
              CalculatorError.syntax,
              'Missing operator between numbers.',
            );
          }
          values.add(token.number!);
          expectOperand = false;

        case TokenType.constant:
          if (!expectOperand) {
            throw const CalculatorException(
              CalculatorError.syntax,
              'Missing operator before constant.',
            );
          }
          values.add(token.value == 'π' ? math.pi : math.e);
          expectOperand = false;

        case TokenType.function:
          if (!expectOperand) {
            throw const CalculatorException(
              CalculatorError.syntax,
              'Missing operator before function.',
            );
          }
          operators.add(token);
          expectOperand = true;

        case TokenType.leftParen:
          if (!expectOperand) {
            throw const CalculatorException(
              CalculatorError.syntax,
              'Missing operator before parenthesis.',
            );
          }
          operators.add(token);
          expectOperand = true;

        case TokenType.rightParen:
          if (expectOperand) {
            throw const CalculatorException(
              CalculatorError.syntax,
              'Nothing to close here.',
            );
          }
          _closeParenthesis(operators, values, angleMode);
          expectOperand = false;

        case TokenType.operator:
          if (expectOperand) {
            if (token.value == '+' || token.value == '-') {
              operators.add(
                Token(type: TokenType.operator, value: token.value == '-' ? 'u-' : 'u+'),
              );
              continue;
            }
            throw const CalculatorException(
              CalculatorError.syntax,
              'An operator is missing a value.',
            );
          }
          _reduceForOperator(operators, values, token.value, angleMode);
          operators.add(token);
          expectOperand = true;

        case TokenType.postfix:
          if (expectOperand) {
            throw const CalculatorException(
              CalculatorError.syntax,
              'Nothing to apply this to.',
            );
          }
          _applyPostfix(token.value, operators, values);
          expectOperand = false;
      }
    }

    if (expectOperand) {
      throw const CalculatorException(
        CalculatorError.syntax,
        'The expression is incomplete.',
      );
    }
    _reduceAll(operators, values, angleMode);
    if (values.length != 1) {
      throw const CalculatorException(
        CalculatorError.syntax,
        'This expression cannot be resolved.',
      );
    }
    return _checked(values.single);
  }

  static EvaluationValue? preview(
    String expression, {
    AngleMode angleMode = AngleMode.degrees,
  }) {
    if (expression.trim().isEmpty || _isLikelyIncomplete(expression)) return null;
    try {
      return EvaluationValue(
        evaluate(expression, angleMode: angleMode),
      );
    } on CalculatorException catch (error) {
      if (error.error == CalculatorError.syntax ||
          error.error == CalculatorError.unknownToken) {
        return null;
      }
      rethrow;
    }
  }

  static bool _isLikelyIncomplete(String expression) {
    final trimmed = expression.trimRight();
    if (trimmed.isEmpty) return true;
    final last = trimmed.substring(trimmed.length - 1);
    return '+-*/^('.contains(last) || _isFunctionTail(trimmed);
  }

  static bool _isFunctionTail(String expression) {
    final match = RegExp(r'(sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|ln|log|sqrt|exp|abs|fact)$')
        .firstMatch(expression.toLowerCase());
    return match != null;
  }

  static void _closeParenthesis(
    List<Token> operators,
    List<double> values,
    AngleMode angleMode,
  ) {
    var found = false;
    while (operators.isNotEmpty) {
      final token = operators.removeLast();
      if (token.type == TokenType.leftParen) {
        found = true;
        break;
      }
      _applyOperator(token, values, angleMode);
    }
    if (!found) {
      throw const CalculatorException(
        CalculatorError.syntax,
        'There is a closing parenthesis without an opening one.',
      );
    }
    if (operators.isNotEmpty && operators.last.type == TokenType.function) {
      _applyOperator(operators.removeLast(), values, angleMode);
    }
  }

  static void _reduceForOperator(
    List<Token> operators,
    List<double> values,
    String incoming,
    AngleMode angleMode,
  ) {
    final incomingPrecedence = _precedence(incoming);
    final incomingRightAssociative = _isRightAssociative(incoming);
    while (operators.isNotEmpty) {
      final top = operators.last;
      if (top.type == TokenType.leftParen) break;
      final topPrecedence = _precedence(top.value);
      final shouldApply = topPrecedence > incomingPrecedence ||
          (topPrecedence == incomingPrecedence && !incomingRightAssociative);
      if (!shouldApply) break;
      _applyOperator(operators.removeLast(), values, angleMode);
    }
  }

  static void _reduceAll(
    List<Token> operators,
    List<double> values,
    AngleMode angleMode,
  ) {
    while (operators.isNotEmpty) {
      final token = operators.removeLast();
      if (token.type == TokenType.leftParen) {
        throw const CalculatorException(
          CalculatorError.syntax,
          'A parenthesis was not closed.',
        );
      }
      _applyOperator(token, values, angleMode);
    }
  }

  static void _applyPostfix(
    String symbol,
    List<Token> operators,
    List<double> values,
  ) {
    if (values.isEmpty) {
      throw const CalculatorException(
        CalculatorError.syntax,
        'Nothing to apply this to.',
      );
    }
    if (symbol == '!') {
      final value = values.removeLast();
      values.add(_factorial(value));
      return;
    }
    final value = values.removeLast() / 100;
    if (operators.isNotEmpty &&
        (operators.last.value == '+' || operators.last.value == '-') &&
        values.isNotEmpty) {
      values.add(values.last * value);
    } else {
      values.add(value);
    }
  }

  static void _applyOperator(
    Token token,
    List<double> values,
    AngleMode angleMode,
  ) {
    if (token.type == TokenType.function) {
      if (values.isEmpty) {
        throw const CalculatorException(
          CalculatorError.syntax,
          'A function is missing its value.',
        );
      }
      final argument = values.removeLast();
      values.add(_applyFunction(token.value, argument, angleMode));
      return;
    }

    if (token.value == 'u-' || token.value == 'u+') {
      if (values.isEmpty) {
        throw const CalculatorException(
          CalculatorError.syntax,
          'A sign is missing its value.',
        );
      }
      final value = values.removeLast();
      values.add(token.value == 'u-' ? -value : value);
      return;
    }

    if (values.length < 2) {
      throw const CalculatorException(
        CalculatorError.syntax,
        'An operator is missing a value.',
      );
    }
    final right = values.removeLast();
    final left = values.removeLast();
    switch (token.value) {
      case '+':
        values.add(left + right);
      case '-':
        values.add(left - right);
      case '*':
        values.add(left * right);
      case '/':
        if (right == 0) {
          throw const CalculatorException(
            CalculatorError.divisionByZero,
            'Cannot divide by zero.',
          );
        }
        values.add(left / right);
      case '^':
        final result = math.pow(left, right).toDouble();
        if (result.isNaN) {
          throw const CalculatorException(
            CalculatorError.invalidDomain,
            'That power is not a real number.',
          );
        }
        values.add(result);
      default:
        throw CalculatorException(
          CalculatorError.unknownToken,
          'Unknown operator "${token.value}".',
        );
    }
    _checked(values.last);
  }

  static double _applyFunction(
    String name,
    double value,
    AngleMode angleMode,
  ) {
    final toRadians = angleMode == AngleMode.degrees;
    double fromRadians(double radians) =>
        toRadians ? radians * 180 / math.pi : radians;
    double toAngle(double input) =>
        toRadians ? input * math.pi / 180 : input;

    switch (name) {
      case 'sin':
        return math.sin(toAngle(value));
      case 'cos':
        return math.cos(toAngle(value));
      case 'tan':
        return math.tan(toAngle(value));
      case 'asin':
        return fromRadians(math.asin(_clamped(value, -1, 1)));
      case 'acos':
        return fromRadians(math.acos(_clamped(value, -1, 1)));
      case 'atan':
        return fromRadians(math.atan(value));
      case 'sinh':
        return math.sinh(value);
      case 'cosh':
        return math.cosh(value);
      case 'tanh':
        return math.tanh(value);
      case 'ln':
        if (value <= 0) {
          throw const CalculatorException(
            CalculatorError.invalidDomain,
            'ln is only defined for positive numbers.',
          );
        }
        return math.log(value);
      case 'log':
        if (value <= 0) {
          throw const CalculatorException(
            CalculatorError.invalidDomain,
            'log is only defined for positive numbers.',
          );
        }
        return math.log(value) / math.ln10;
      case 'sqrt':
        if (value < 0) {
          throw const CalculatorException(
            CalculatorError.invalidDomain,
            'Square root of a negative number is not real.',
          );
        }
        return math.sqrt(value);
      case 'exp':
        return math.exp(value);
      case 'abs':
        return value.abs();
      case 'fact':
        return _factorial(value);
      case 'floor':
        return value.floorToDouble();
      case 'ceil':
        return value.ceilToDouble();
      case 'round':
        return value.roundToDouble();
      default:
        throw CalculatorException(
          CalculatorError.unknownToken,
          'Unknown function "$name".',
        );
    }
  }

  static double _factorial(double value) {
    if (value < 0 || value > 170 || (value - value.roundToDouble()).abs() > 1e-9) {
      throw const CalculatorException(
        CalculatorError.invalidDomain,
        'Factorial needs a whole number from 0 to 170.',
      );
    }
    var result = 1.0;
    for (var i = 2; i <= value.round(); i++) {
      result *= i;
    }
    return _checked(result);
  }

  static double _clamped(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static double _checked(double value) {
    if (value.isInfinite) {
      throw const CalculatorException(
        CalculatorError.overflow,
        'That number is too large to display.',
      );
    }
    if (value.isNaN) {
      throw const CalculatorException(
        CalculatorError.invalidDomain,
        'That expression has no real result.',
      );
    }
    return value;
  }

  static int _precedence(String operator) {
    return switch (operator) {
      '+' || '-' => 1,
      '*' || '/' => 2,
      'u+' || 'u-' => 3,
      '^' => 4,
      _ => 5,
    };
  }

  static bool _isRightAssociative(String operator) {
    return operator == '^' || operator == 'u+' || operator == 'u-';
  }
}
