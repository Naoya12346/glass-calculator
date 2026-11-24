import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/glass_container.dart';
import '../data/settings_provider.dart';
import '../data/settings_state.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final state = settings.state;
    final strings = AppStrings(state.language);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(strings.settings, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(strings.appearance,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      for (final mode in AppThemeMode.values)
                        _ChoiceChip(
                          label: _themeLabel(mode, strings),
                          selected: state.themeMode == mode,
                          onSelected: () => settings.setThemeMode(mode),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(strings.accentColor,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.md,
                    children: <Widget>[
                      for (final color in AppColors.accents)
                        Semantics(
                          label: 'Accent ${color.toARGB32().toRadixString(16)}',
                          child: GestureDetector(
                            onTap: () => settings.setAccent(color),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: state.accent == color ? 40 : 32,
                              height: state.accent == color ? 40 : 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(
                                  color: state.accent == color
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.45),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassContainer(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text(strings.haptics),
                    value: state.haptics,
                    onChanged: settings.setHaptics,
                  ),
                  SwitchListTile(
                    title: Text(strings.sound),
                    value: state.sound,
                    onChanged: settings.setSound,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${strings.precision}: ${state.precision}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: state.precision.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: state.precision.toString(),
                    onChanged: (value) => settings.setPrecision(value.round()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<NumberFormatMode>(
                    initialValue: state.numberFormat,
                    decoration: InputDecoration(
                      labelText: strings.numberFormat,
                      border: const OutlineInputBorder(),
                    ),
                    items: <DropdownMenuItem<NumberFormatMode>>[
                      DropdownMenuItem(
                        value: NumberFormatMode.international,
                        child: Text(strings.international),
                      ),
                      DropdownMenuItem(
                        value: NumberFormatMode.indian,
                        child: Text(strings.indian),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) settings.setNumberFormat(value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<AppLanguage>(
                    initialValue: state.language,
                    decoration: InputDecoration(
                      labelText: strings.languageLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: <DropdownMenuItem<AppLanguage>>[
                      DropdownMenuItem(
                        value: AppLanguage.english,
                        child: Text(strings.english),
                      ),
                      DropdownMenuItem(
                        value: AppLanguage.hindi,
                        child: Text(strings.hindi),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) settings.setLanguage(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(AppThemeMode mode, AppStrings strings) {
    return switch (mode) {
      AppThemeMode.system => strings.system,
      AppThemeMode.light => strings.light,
      AppThemeMode.dark => strings.dark,
      AppThemeMode.amoled => strings.amoled,
    };
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
