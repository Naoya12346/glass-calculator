import 'calculator_exception.dart';
import 'token.dart';

class Tokenizer {
  const Tokenizer._();

  static List<Token> tokenize(String input) {
    final expression = _normalize(input);
    final tokens = <Token>[];
    var i = 0;

    while (i < expression.length) {
      final code = expression.codeUnitAt(i);

      if (_isDigit(code) || code == _dot) {
        final buffer = StringBuffer();
        var dots = 0;
        while (i < expression.length) {
          final current = expression.codeUnitAt(i);
          if (_isDigit(current)) {
            buffer.writeCharCode(current);
          } else if (current == _dot) {
            dots++;
            if (dots > 1) {
              throw const CalculatorException(
                CalculatorError.syntax,
                'A number can only contain one decimal point.',
              );
            }
            buffer.writeCharCode(current);
          } else {
            break;
          }
          i++;
        }
        tokens.add(
          Token(
            type: TokenType.number,
            value: buffer.toString(),
            number: double.parse(buffer.toString()),
          ),
        );
        continue;
      }

      final char = expression[i];
      if (char == '+' || char == '-' || char == '*' || char == '/' || char == '^') {
        tokens.add(Token(type: TokenType.operator, value: char));
        i++;
        continue;
      }
      if (char == '(') {
        tokens.add(const Token(type: TokenType.leftParen, value: '('));
        i++;
        continue;
      }
      if (char == ')') {
        tokens.add(const Token(type: TokenType.rightParen, value: ')'));
        i++;
        continue;
      }
      if (char == '%') {
        tokens.add(const Token(type: TokenType.postfix, value: '%'));
        i++;
        continue;
      }
      if (char == '!') {
        tokens.add(const Token(type: TokenType.postfix, value: '!'));
        i++;
        continue;
      }
      if (char == ',') {
        i++;
        continue;
      }
      if (code == _sqrt || code == _pi) {
        tokens.add(_identifierToken(String.fromCharCode(code)));
        i++;
        continue;
      }
      if (_isIdentifierStart(code)) {
        final buffer = StringBuffer();
        while (i < expression.length &&
            _isIdentifierPart(expression.codeUnitAt(i))) {
          buffer.writeCharCode(expression.codeUnitAt(i));
          i++;
        }
        tokens.add(_identifierToken(buffer.toString()));
        continue;
      }

      throw CalculatorException(
        CalculatorError.unknownToken,
        'I do not understand "$char" yet.',
      );
    }

    return _insertImplicitMultiplication(tokens);
  }

  static Token _identifierToken(String raw) {
    final name = raw.toLowerCase();
    if (raw == 'π' || name == 'pi') {
      return const Token(type: TokenType.constant, value: 'π');
    }
    if (name == 'e') {
      return const Token(type: TokenType.constant, value: 'e');
    }
    if (raw == '√' || name == 'sqrt' || name == 'root') {
      return const Token(type: TokenType.function, value: 'sqrt');
    }
    const functionAliases = <String, String>{
      'sin': 'sin',
      'cos': 'cos',
      'tan': 'tan',
      'asin': 'asin',
      'acos': 'acos',
      'atan': 'atan',
      'sinh': 'sinh',
      'cosh': 'cosh',
      'tanh': 'tanh',
      'ln': 'ln',
      'log': 'log',
      'lg': 'log',
      'exp': 'exp',
      'abs': 'abs',
      'fact': 'fact',
      'floor': 'floor',
      'ceil': 'ceil',
      'round': 'round',
    };
    final function = functionAliases[name];
    if (function != null) {
      return Token(type: TokenType.function, value: function);
    }
    throw CalculatorException(
      CalculatorError.unknownToken,
      'Unknown function "$raw".',
    );
  }

  static List<Token> _insertImplicitMultiplication(List<Token> tokens) {
    final result = <Token>[];
    for (final token in tokens) {
      if (result.isNotEmpty &&
          _endsValue(result.last) &&
          _startsValue(token)) {
        result.add(const Token(type: TokenType.operator, value: '*'));
      }
      result.add(token);
    }
    return result;
  }

  static bool _endsValue(Token token) {
    return token.type == TokenType.number ||
        token.type == TokenType.constant ||
        token.type == TokenType.rightParen ||
        token.type == TokenType.postfix;
  }

  static bool _startsValue(Token token) {
    return token.type == TokenType.number ||
        token.type == TokenType.constant ||
        token.type == TokenType.leftParen ||
        token.type == TokenType.function;
  }

  static String _normalize(String input) {
    return input
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll(RegExp(r'\s+'), '');
  }

  static bool _isDigit(int code) => code >= _zero && code <= _nine;

  static bool _isIdentifierStart(int code) {
    return (code >= _upperA && code <= _upperZ) ||
        (code >= _lowerA && code <= _lowerZ) ||
        code == _sqrt || code == _pi;
  }

  static bool _isIdentifierPart(int code) {
    return _isIdentifierStart(code) || code == _underscore;
  }

  static const int _dot = 46;
  static const int _zero = 48;
  static const int _nine = 57;
  static const int _upperA = 65;
  static const int _upperZ = 90;
  static const int _lowerA = 97;
  static const int _lowerZ = 122;
  static const int _underscore = 95;
  static const int _sqrt = 8730;
  static const int _pi = 960;
}
