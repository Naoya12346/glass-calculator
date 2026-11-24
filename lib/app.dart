import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_durations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/settings/data/settings_provider.dart';
import 'features/settings/data/settings_state.dart';
import 'shell.dart';

class CalculatorApp extends ConsumerWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final resolvedMode = settings.themeMode == AppThemeMode.system
        ? (platformBrightness == Brightness.dark
            ? AppThemeMode.dark
            : AppThemeMode.light)
        : settings.themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glass Calculator',
      theme: AppTheme.themeData(resolvedMode, settings.accent),
      themeMode: resolvedMode == AppThemeMode.amoled ||
              resolvedMode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      themeAnimationDuration: AppDurations.theme,
      themeAnimationCurve: Curves.easeInOutCubic,
      home: const Shell(),
      builder: (context, child) {
        return ThemeProvider(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
