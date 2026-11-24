import 'package:material_ui/material_ui.dart';

enum AppThemeMode { system, light, dark, amoled }

enum NumberFormatMode { international, indian }

enum AppLanguage { english, hindi }

class SettingsState {
  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.accent = const Color(0xFF4C8DFF),
    this.haptics = true,
    this.sound = false,
    this.precision = 6,
    this.numberFormat = NumberFormatMode.international,
    this.language = AppLanguage.english,
  });

  final AppThemeMode themeMode;
  final Color accent;
  final bool haptics;
  final bool sound;
  final int precision;
  final NumberFormatMode numberFormat;
  final AppLanguage language;

  SettingsState copyWith({
    AppThemeMode? themeMode,
    Color? accent,
    bool? haptics,
    bool? sound,
    int? precision,
    NumberFormatMode? numberFormat,
    AppLanguage? language,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      haptics: haptics ?? this.haptics,
      sound: sound ?? this.sound,
      precision: precision ?? this.precision,
      numberFormat: numberFormat ?? this.numberFormat,
      language: language ?? this.language,
    );
  }
}
