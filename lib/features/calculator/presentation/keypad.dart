import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/glass_button.dart';

class BasicKeypad extends StatelessWidget {
  const BasicKeypad({
    required this.onAction,
    super.key,
    this.compact = false,
  });

  final ValueChanged<String> onAction;
  final bool compact;

  static const List<_KeyDefinition> _keys = <_KeyDefinition>[
    _KeyDefinition('C', 'C', GlassButtonKind.danger),
    _KeyDefinition('⌫', 'backspace', GlassButtonKind.danger),
    _KeyDefinition('(', '(', GlassButtonKind.function),
    _KeyDefinition(')', ')', GlassButtonKind.function),
    _KeyDefinition('7', '7', GlassButtonKind.digit),
    _KeyDefinition('8', '8', GlassButtonKind.digit),
    _KeyDefinition('9', '9', GlassButtonKind.digit),
    _KeyDefinition('÷', '/', GlassButtonKind.operator),
    _KeyDefinition('4', '4', GlassButtonKind.digit),
    _KeyDefinition('5', '5', GlassButtonKind.digit),
    _KeyDefinition('6', '6', GlassButtonKind.digit),
    _KeyDefinition('×', '*', GlassButtonKind.operator),
    _KeyDefinition('1', '1', GlassButtonKind.digit),
    _KeyDefinition('2', '2', GlassButtonKind.digit),
    _KeyDefinition('3', '3', GlassButtonKind.digit),
    _KeyDefinition('−', '-', GlassButtonKind.operator),
    _KeyDefinition('±', 'sign', GlassButtonKind.function),
    _KeyDefinition('0', '0', GlassButtonKind.digit),
    _KeyDefinition('.', '.', GlassButtonKind.digit),
    _KeyDefinition('+', '+', GlassButtonKind.operator),
    _KeyDefinition('%', '%', GlassButtonKind.function),
    _KeyDefinition('√', 'sqrt', GlassButtonKind.function),
    _KeyDefinition('x²', 'square', GlassButtonKind.function),
    _KeyDefinition('=', 'equals', GlassButtonKind.accent),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const rows = 6;
        final gap = AppSpacing.sm;
        final cellWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final availableHeight =
            compact ? cellWidth : constraints.maxHeight - gap * (rows - 1);
        final cellHeight = Responsive.clamp(
          availableHeight / rows,
          AppSpacing.minTouchTarget,
          compact ? 66 : 92,
        );
        final fontSize = Responsive.clamp(cellHeight * 0.34, 17, 27);

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (var i = 0; i < _keys.length; i++)
              RepaintBoundary(
                child: SizedBox(
                  width: cellWidth,
                  height: cellHeight,
                  child: GlassButton(
                    label: _keys[i].label,
                    value: _keys[i].label,
                    onTap: () => onAction(_keys[i].action),
                    kind: _keys[i].kind,
                    semanticsLabel: _keys[i].semantics,
                    fontSize: fontSize,
                  ),
                )
                    .animate(delay: Duration(milliseconds: 18 * i))
                    .fadeIn(duration: AppDurations.normal)
                    .slideY(begin: 0.16, end: 0),
              ),
          ],
        );
      },
    );
  }
}

class ScientificPad extends StatelessWidget {
  const ScientificPad({required this.onAction, super.key});

  final ValueChanged<String> onAction;

  static const List<_KeyDefinition> _keys = <_KeyDefinition>[
    _KeyDefinition('sin', 'sin', GlassButtonKind.function),
    _KeyDefinition('cos', 'cos', GlassButtonKind.function),
    _KeyDefinition('tan', 'tan', GlassButtonKind.function),
    _KeyDefinition('sin⁻¹', 'asin', GlassButtonKind.function),
    _KeyDefinition('cos⁻¹', 'acos', GlassButtonKind.function),
    _KeyDefinition('sinh', 'sinh', GlassButtonKind.function),
    _KeyDefinition('cosh', 'cosh', GlassButtonKind.function),
    _KeyDefinition('tanh', 'tanh', GlassButtonKind.function),
    _KeyDefinition('tan⁻¹', 'atan', GlassButtonKind.function),
    _KeyDefinition('ln', 'ln', GlassButtonKind.function),
    _KeyDefinition('log', 'log', GlassButtonKind.function),
    _KeyDefinition('eˣ', 'exp', GlassButtonKind.function),
    _KeyDefinition('xʸ', '^', GlassButtonKind.operator),
    _KeyDefinition('n!', 'fact', GlassButtonKind.function),
    _KeyDefinition('π', 'π', GlassButtonKind.function),
    _KeyDefinition('e', 'e', GlassButtonKind.function),
    _KeyDefinition('M+', 'mAdd', GlassButtonKind.operator),
    _KeyDefinition('M−', 'mSub', GlassButtonKind.operator),
    _KeyDefinition('MR', 'mRecall', GlassButtonKind.operator),
    _KeyDefinition('MC', 'mClear', GlassButtonKind.operator),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 5;
        final gap = AppSpacing.xs;
        final cellWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final cellHeight = Responsive.clamp(cellWidth * 0.68, 44, 62);
        final fontSize = Responsive.clamp(cellHeight * 0.28, 11, 17);

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (var i = 0; i < _keys.length; i++)
              RepaintBoundary(
                child: SizedBox(
                  width: cellWidth,
                  height: cellHeight,
                  child: GlassButton(
                    label: _keys[i].label,
                    value: _keys[i].label,
                    onTap: () => onAction(_keys[i].action),
                    kind: _keys[i].kind,
                    semanticsLabel: _keys[i].semantics,
                    fontSize: fontSize,
                  ),
                )
                    .animate(delay: Duration(milliseconds: 12 * i))
                    .fadeIn(duration: AppDurations.normal)
                    .slideY(begin: 0.12, end: 0),
              ),
          ],
        );
      },
    );
  }
}

class _KeyDefinition {
  const _KeyDefinition(this.label, this.action, this.kind)
      : semantics = label;

  final String label;
  final String action;
  final GlassButtonKind kind;
  final String semantics;
}
