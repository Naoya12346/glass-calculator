import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../core/utils/number_text_formatter.dart';
import '../../../core/widgets/glass_container.dart';
import '../../history/data/history_provider.dart';
import '../../settings/data/settings_provider.dart';
import '../domain/calculator_exception.dart';
import '../domain/evaluator.dart';
import '../providers/calculator_provider.dart';
import 'animated_display.dart';
import 'history_sheet.dart';
import 'keypad.dart';

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  bool _scientificOverride = false;

  @override
  Widget build(BuildContext context) {
    final expression = ref.watch(expressionProvider);
    final settings = ref.watch(settingsProvider);
    final strings = AppStrings(settings.state.language);

    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight ||
            constraints.maxHeight < 480;
        final showScientific = landscape ||
            constraints.maxWidth >= 720 ||
            _scientificOverride;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(
                strings: strings,
                showScientific: showScientific,
                canToggleScientific:
                    !landscape && constraints.maxWidth < 720,
                onToggleScientific: () {
                  setState(() {
                    _scientificOverride = !_scientificOverride;
                  });
                },
                onHistory: () => showHistorySheet(context),
                angleMode: expression.angleMode,
                onToggleAngle: () {
                  FeedbackService.tap(ref);
                  expression.toggleAngleMode();
                },
                hasMemory: expression.hasMemory,
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                flex: landscape ? 2 : 3,
                child: GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AnimatedDisplay(
                    expression: expression.expression,
                    preview: expression.preview,
                    error: expression.error,
                    errorVersion: expression.errorVersion,
                    onExpressionChanged: (value) {
                      expression.setExpression(value);
                    },
                    onSelectionChanged: (value) {
                      expression.setSelection(value);
                    },
                    onBackspace: expression.backspace,
                    onDeleteForward: expression.deleteForward,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                flex: landscape ? 3 : 5,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (showScientific) ...<Widget>[
                        ScientificPad(onAction: _handleAction),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      BasicKeypad(
                        onAction: _handleAction,
                        compact: landscape,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAction(String action) {
    final expression = ref.read(expressionProvider);
    switch (action) {
      case 'C':
        expression.clear();
      case 'backspace':
        expression.backspace();
      case 'sign':
        expression.toggleSign();
      case '%':
        expression.insert('%');
      case 'equals':
        _equals();
      case 'sqrt':
        expression.insert('√(');
      case 'square':
        expression.insert('^2');
      case 'fact':
        expression.insert('!');
      case 'exp':
        expression.insert('exp(');
      case 'sin':
      case 'cos':
      case 'tan':
      case 'asin':
      case 'acos':
      case 'atan':
      case 'sinh':
      case 'cosh':
      case 'tanh':
      case 'ln':
      case 'log':
        expression.insert('$action(');
      case 'π':
      case 'e':
      case '(':
      case ')':
      case '.':
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
      case '+':
      case '-':
      case '*':
      case '/':
      case '^':
        expression.insert(action);
      case 'mAdd':
        expression.memoryAdd(expression.preview ?? 0);
      case 'mSub':
        expression.memorySubtract(expression.preview ?? 0);
      case 'mRecall':
        expression.memoryRecall();
      case 'mClear':
        expression.memoryClear();
    }
  }

  void _equals() {
    final expression = ref.read(expressionProvider);
    try {
      final value = expression.evaluateNow();
      final settings = ref.read(settingsProvider);
      final formatted = NumberTextFormatter.format(value, settings.state);
      ref.read(historyProvider).add(
            expression: expression.expression,
            result: formatted,
          );
      expression.commitResult(value, formatted);
    } on CalculatorException {
      FeedbackService.error(ref);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.strings,
    required this.showScientific,
    required this.canToggleScientific,
    required this.onToggleScientific,
    required this.onHistory,
    required this.angleMode,
    required this.onToggleAngle,
    required this.hasMemory,
  });

  final AppStrings strings;
  final bool showScientific;
  final bool canToggleScientific;
  final VoidCallback onToggleScientific;
  final VoidCallback onHistory;
  final AngleMode angleMode;
  final VoidCallback onToggleAngle;
  final bool hasMemory;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            strings.calculator,
            style: Theme.of(context).textTheme.headlineMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasMemory)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Text(
              'M',
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
        _Chip(
          label: angleMode == AngleMode.degrees ? strings.deg : strings.rad,
          onTap: onToggleAngle,
        ),
        const SizedBox(width: AppSpacing.xs),
        if (canToggleScientific)
          IconButton(
            tooltip: showScientific ? strings.standard : strings.scientific,
            onPressed: onToggleScientific,
            icon: Icon(
              showScientific ? Icons.expand_less : Icons.science_outlined,
            ),
          ),
        IconButton(
          tooltip: strings.history,
          onPressed: onHistory,
          icon: const Icon(Icons.history),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.pillRadius,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.pillRadius,
            border: Border.all(color: accent.withValues(alpha: 0.45)),
            color: accent.withValues(alpha: 0.10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
