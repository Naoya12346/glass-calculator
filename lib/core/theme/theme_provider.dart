import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/data/settings_provider.dart';
import '../constants/app_durations.dart';
import 'app_theme.dart';

class ThemeProvider extends ConsumerWidget {
  const ThemeProvider({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final resolvedMode = settings.themeMode == AppThemeMode.system
        ? (platformBrightness == Brightness.dark
            ? AppThemeMode.dark
            : AppThemeMode.light)
        : settings.themeMode;
    return AnimatedTheme(
      data: AppTheme.themeData(resolvedMode, settings.accent),
      duration: AppDurations.theme,
      curve: Curves.easeInOutCubic,
      child: child,
    );
  }
}
