enum TokenType {
  number,
  operator,
  function,
  leftParen,
  rightParen,
  constant,
  postfix,
}

class Token {
  const Token({
    required this.type,
    required this.value,
    this.number,
  });

  final TokenType type;
  final String value;
  final double? number;

  @override
  String toString() => 'Token(${type.name}, $value)';
}
