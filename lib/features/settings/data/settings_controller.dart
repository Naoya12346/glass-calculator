import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import 'settings_state.dart';

class SettingsController extends ChangeNotifier {
  SettingsState _state = const SettingsState();
  SharedPreferences? _prefs;

  SettingsState get state => _state;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;
    final accentValue =
        prefs.getInt(_Keys.accent) ?? AppColors.accents.first.toARGB32();
    _state = SettingsState(
      themeMode: _themeFromIndex(prefs.getInt(_Keys.themeMode) ?? 0),
      accent: AppColors.accents.contains(Color(accentValue))
          ? Color(accentValue)
          : AppColors.accents.first,
      haptics: prefs.getBool(_Keys.haptics) ?? true,
      sound: prefs.getBool(_Keys.sound) ?? false,
      precision: (prefs.getInt(_Keys.precision) ?? 6).clamp(0, 10),
      numberFormat: _formatFromIndex(prefs.getInt(_Keys.numberFormat) ?? 0),
      language: _languageFromIndex(prefs.getInt(_Keys.language) ?? 0),
    );
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode value) async {
    _state = _state.copyWith(themeMode: value);
    await _write((prefs) => prefs.setInt(_Keys.themeMode, value.index));
  }

  Future<void> setAccent(Color value) async {
    _state = _state.copyWith(accent: value);
    await _write((prefs) => prefs.setInt(_Keys.accent, value.toARGB32()));
  }

  Future<void> setHaptics(bool value) async {
    _state = _state.copyWith(haptics: value);
    await _write((prefs) => prefs.setBool(_Keys.haptics, value));
  }

  Future<void> setSound(bool value) async {
    _state = _state.copyWith(sound: value);
    await _write((prefs) => prefs.setBool(_Keys.sound, value));
  }

  Future<void> setPrecision(int value) async {
    final safe = value.clamp(0, 10);
    _state = _state.copyWith(precision: safe);
    await _write((prefs) => prefs.setInt(_Keys.precision, safe));
  }

  Future<void> setNumberFormat(NumberFormatMode value) async {
    _state = _state.copyWith(numberFormat: value);
    await _write((prefs) => prefs.setInt(_Keys.numberFormat, value.index));
  }

  Future<void> setLanguage(AppLanguage value) async {
    _state = _state.copyWith(language: value);
    await _write((prefs) => prefs.setInt(_Keys.language, value.index));
  }

  Future<void> _write(Future<bool> Function(SharedPreferences prefs) write) async {
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await write(prefs);
  }

  AppThemeMode _themeFromIndex(int index) {
    if (index >= 0 && index < AppThemeMode.values.length) {
      return AppThemeMode.values[index];
    }
    return AppThemeMode.system;
  }

  NumberFormatMode _formatFromIndex(int index) {
    if (index >= 0 && index < NumberFormatMode.values.length) {
      return NumberFormatMode.values[index];
    }
    return NumberFormatMode.international;
  }

  AppLanguage _languageFromIndex(int index) {
    if (index >= 0 && index < AppLanguage.values.length) {
      return AppLanguage.values[index];
    }
    return AppLanguage.english;
  }
}

class _Keys {
  const _Keys._();

  static const String themeMode = 'settings.theme_mode';
  static const String accent = 'settings.accent';
  static const String haptics = 'settings.haptics';
  static const String sound = 'settings.sound';
  static const String precision = 'settings.precision';
  static const String numberFormat = 'settings.number_format';
  static const String language = 'settings.language';
}
