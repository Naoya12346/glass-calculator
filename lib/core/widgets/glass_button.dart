import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/data/settings_provider.dart';
import '../constants/app_durations.dart';
import '../constants/app_spacing.dart';
import '../utils/feedback_service.dart';
import 'glass_container.dart';

enum GlassButtonKind { digit, function, operator, accent, danger }

class GlassButton extends ConsumerStatefulWidget {
  const GlassButton({
    required this.label,
    required this.onTap,
    super.key,
    this.value,
    this.kind = GlassButtonKind.digit,
    this.semanticsLabel,
    this.flex = 1,
    this.fontSize = 22,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final GlassButtonKind kind;
  final String? semanticsLabel;
  final int flex;
  final double fontSize;

  @override
  ConsumerState<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends ConsumerState<GlassButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = settings.accent;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = _foreground(accent, isDark);
    final fill = _fill(accent, isDark);
    final alignedLabel = widget.value ?? widget.label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        label: widget.semanticsLabel ?? widget.label,
        child: AnimatedScale(
          scale: _pressed ? 0.93 : (_hovered ? 1.035 : 1),
          duration: AppDurations.fast,
          curve: Curves.easeOutBack,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppSpacing.buttonRadius,
              splashColor: accent.withValues(alpha: 0.20),
              highlightColor: accent.withValues(alpha: 0.10),
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: () {
                FeedbackService.tap(
                  ref,
                  strong: widget.kind == GlassButtonKind.operator ||
                      widget.kind == GlassButtonKind.accent,
                );
                widget.onTap();
              },
              child: GlassContainer(
                borderRadius: AppSpacing.buttonRadius,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                blur: 12,
                opacity: fill.opacity,
                borderOpacity: _hovered ? 0.58 : 0.26,
                child: AnimatedContainer(
                  duration: AppDurations.normal,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.minTouchTarget,
                    minWidth: AppSpacing.minTouchTarget,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.buttonRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        fill.color.withValues(alpha: _hovered ? 0.30 : 0.18),
                        fill.color.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                  child: Text(
                    alignedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: widget.fontSize,
                      fontWeight: widget.kind == GlassButtonKind.operator ||
                              widget.kind == GlassButtonKind.accent
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontFeatures: <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ({Color color, double opacity}) _fill(Color accent, bool isDark) {
    switch (widget.kind) {
      case GlassButtonKind.accent:
        return (color: accent, opacity: 0.46);
      case GlassButtonKind.operator:
        return (color: accent, opacity: 0.24);
      case GlassButtonKind.function:
        return (color: isDark ? Colors.white : Colors.indigo, opacity: 0.08);
      case GlassButtonKind.danger:
        return (color: AppColorsDanger.color, opacity: 0.20);
      case GlassButtonKind.digit:
        return (color: isDark ? Colors.white : Colors.black, opacity: 0.07);
    }
  }

  Color _foreground(Color accent, bool isDark) {
    switch (widget.kind) {
      case GlassButtonKind.accent:
      case GlassButtonKind.operator:
        return accent;
      case GlassButtonKind.danger:
        return AppColorsDanger.color;
      case GlassButtonKind.function:
      case GlassButtonKind.digit:
        return isDark ? Colors.white : Colors.black87;
    }
  }
}

class AppColorsDanger {
  const AppColorsDanger._();

  static const Color color = Color(0xFFFF6B7A);
}
