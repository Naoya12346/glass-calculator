import 'package:flutter/foundation.dart';

import 'calculator_exception.dart';
import 'evaluator.dart';

class ExpressionController extends ChangeNotifier {
  ExpressionController();

  String _expression = '';
  int _selection = 0;
  double? _preview;
  String? _error;
  int _errorVersion = 0;
  AngleMode _angleMode = AngleMode.degrees;
  double _memory = 0;
  bool _memoryVisible = false;

  String get expression => _expression;
  int get selection => _selection;
  double? get preview => _preview;
  String? get error => _error;
  int get errorVersion => _errorVersion;
  AngleMode get angleMode => _angleMode;
  double get memory => _memory;
  bool get memoryVisible => _memoryVisible;
  bool get hasMemory => _memory != 0 || _memoryVisible;

  void insert(String text) {
    if (text.isEmpty) return;
    final start = _selection.clamp(0, _expression.length);
    final end = start;
    _expression = _expression.substring(0, start) + text + _expression.substring(end);
    _selection = start + text.length;
    _clearError();
    _refreshPreview();
    notifyListeners();
  }

  void backspace() {
    if (_expression.isEmpty || _selection == 0) return;
    final start = _selection - 1;
    _expression = _expression.substring(0, start) + _expression.substring(_selection);
    _selection = start;
    _clearError();
    _refreshPreview();
    notifyListeners();
  }

  void deleteForward() {
    if (_selection >= _expression.length) return;
    _expression = _expression.substring(0, _selection) +
        _expression.substring(_selection + 1);
    _clearError();
    _refreshPreview();
    notifyListeners();
  }

  void deleteLastToken() {
    if (_expression.isEmpty) return;
    final end = _selection == 0 ? _expression.length : _selection;
    var start = end - 1;
    while (start > 0 && _isPartOfToken(_expression[start - 1], _expression[start])) {
      start--;
    }
    _expression = _expression.substring(0, start) + _expression.substring(end);
    _selection = start;
    _clearError();
    _refreshPreview();
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _selection = 0;
    _clearError();
    _refreshPreview();
    notifyListeners();
  }

  void setExpression(String value) {
    _expression = value;
    _selection = value.length;
    _clearError();
    _refreshPreview();
    notifyListeners();
  }

  void setSelection(int value) {
    _selection = value.clamp(0, _expression.length);
    notifyListeners();
  }

  void toggleSign() {
    if (_expression.isEmpty) {
      insert('-');
      return;
    }
    final cursor = _selection.clamp(0, _expression.length);
    var end = cursor;
    while (end > 0 && _isNumberChar(_expression[end - 1])) {
      end--;
    }
    if (end == cursor) {
      insert('-');
      return;
    }
    final numberStart = end;
    final isNegative = numberStart > 0 && _expression[numberStart - 1] == '-';
    if (isNegative) {
      _expression = _expression.substring(0, numberStart - 1) +
          _expression.substring(numberStart);
      _selection = cursor - 1;
    } else {
      _expression = _expression.substring(0, numberStart) +
          '-' +
          _expression.substring(numberStart);
      _selection = cursor + 1;
    }
    _clearError();
    _refreshPreview();
    notifyListeners();
  }

  double evaluateNow() {
    try {
      final value = ExpressionEvaluator.evaluate(
        _expression,
        angleMode: _angleMode,
      );
      _preview = value;
      _clearError();
      notifyListeners();
      return value;
    } on CalculatorException catch (error) {
      _preview = null;
      _error = error.message;
      _errorVersion++;
      notifyListeners();
      rethrow;
    }
  }

  void commitResult(double value, String formatted) {
    _expression = formatted.replaceAll(RegExp(r'[,_\s]'), '');
    _selection = _expression.length;
    _refreshPreview();
    notifyListeners();
  }

  void toggleAngleMode() {
    _angleMode = _angleMode == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;
    _refreshPreview();
    notifyListeners();
  }

  void memoryAdd(double value) {
    _memory += value;
    _memoryVisible = true;
    notifyListeners();
  }

  void memorySubtract(double value) {
    _memory -= value;
    _memoryVisible = true;
    notifyListeners();
  }

  void memoryRecall() {
    insert(_formatMemory(_memory));
  }

  void memoryClear() {
    _memory = 0;
    _memoryVisible = false;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _refreshPreview() {
    try {
      _preview = ExpressionEvaluator.preview(
        _expression,
        angleMode: _angleMode,
      )?.value;
    } on CalculatorException catch (error) {
      _preview = null;
      _error = error.message;
      _errorVersion++;
    }
  }

  bool _isNumberChar(String char) {
    return (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) || char == '.';
  }

  bool _isPartOfToken(String previous, String current) {
    return _isNumberChar(previous) ||
        (previous == '.' && _isNumberChar(current)) ||
        _isNumberChar(current);
  }

  String _formatMemory(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.round().toString();
    }
    return value.toString();
  }
}
