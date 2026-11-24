import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/number_text_formatter.dart';
import '../../settings/data/settings_provider.dart';

class AnimatedDisplay extends ConsumerStatefulWidget {
  const AnimatedDisplay({
    required this.expression,
    required this.onExpressionChanged,
    required this.onSelectionChanged,
    required this.onBackspace,
    required this.onDeleteForward,
    super.key,
    this.preview,
    this.error,
    this.errorVersion = 0,
  });

  final String expression;
  final double? preview;
  final String? error;
  final int errorVersion;
  final ValueChanged<String> onExpressionChanged;
  final ValueChanged<int> onSelectionChanged;
  final VoidCallback onBackspace;
  final VoidCallback onDeleteForward;

  @override
  ConsumerState<AnimatedDisplay> createState() => _AnimatedDisplayState();
}

class _AnimatedDisplayState extends ConsumerState<AnimatedDisplay>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _shakeController;
  int _lastErrorVersion = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.expression);
    _controller.addListener(_reportSelection);
    _focusNode = FocusNode();
    _shakeController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _lastErrorVersion = widget.errorVersion;
  }

  @override
  void didUpdateWidget(covariant AnimatedDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expression != _controller.text) {
      final cursor = widget.expression.length.clamp(0, widget.expression.length);
      _controller.value = TextEditingValue(
        text: widget.expression,
        selection: TextSelection.collapsed(offset: cursor),
      );
    }
    if (widget.errorVersion != _lastErrorVersion) {
      _lastErrorVersion = widget.errorVersion;
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_reportSelection);
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _reportSelection() {
    widget.onSelectionChanged(_controller.selection.baseOffset);
  }

  Future<void> _showContextMenu(Offset position) async {
    final settings = ref.read(settingsProvider);
    final strings = AppStrings(settings.state.language);
    final screen = MediaQuery.of(context).size;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        screen.width - position.dx,
        screen.height - position.dy,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'copy',
          child: Text(strings.copied.replaceFirst(' to clipboard', '')),
        ),
        const PopupMenuItem<String>(value: 'paste', child: Text('Paste')),
      ],
    );
    if (selected == 'copy') {
      final text = widget.preview != null
          ? NumberTextFormatter.format(widget.preview!, settings.state)
          : _controller.text;
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.copied)),
        );
      }
    } else if (selected == 'paste') {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text != null && text.isNotEmpty && context.mounted) {
        widget.onExpressionChanged(text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final previewText = widget.preview == null
        ? ''
        : NumberTextFormatter.format(widget.preview!, settings.state);
    final hasError = widget.error != null;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -350) {
          widget.onDeleteForward();
        } else if (velocity > 350) {
          widget.onBackspace();
        }
      },
      onLongPressStart: (details) => _showContextMenu(details.globalPosition),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shake = hasError
              ? math.sin(_shakeController.value * 30) *
                  (1 - _shakeController.value) *
                  8
              : 0.0;
          return Transform.translate(offset: Offset(shake, 0), child: child);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: maxWidth,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: widget.onExpressionChanged,
                      textAlign: TextAlign.end,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      autocorrect: false,
                      enableSuggestions: false,
                      cursorColor: settings.state.accent,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: hasError
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurface,
                            fontFeatures: <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedSwitcher(
                  duration: AppDurations.normal,
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.18),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    previewText,
                    key: ValueKey<String>(previewText),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: settings.state.accent,
                          fontWeight: FontWeight.w600,
                          fontFeatures: <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                  ),
                ),
                AnimatedSize(
                  duration: AppDurations.fast,
                  child: hasError
                      ? Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            widget.error!,
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}
