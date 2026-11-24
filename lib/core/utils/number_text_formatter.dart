import 'package:intl/intl.dart';

import '../../features/settings/data/settings_state.dart';

class NumberTextFormatter {
  const NumberTextFormatter._();

  static String format(double value, SettingsState settings) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value.isNegative ? '-∞' : '∞';

    final locale = settings.numberFormat == NumberFormatMode.indian ? 'en_IN' : 'en_US';
    final formatter = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = settings.precision
      ..maximumFractionDigits = settings.precision;
    final text = formatter.format(value);
    if (value == 0 && text.startsWith('-')) return text.substring(1);
    return text;
  }

  static String plain(double value, SettingsState settings) {
    final formatted = format(value, settings);
    return formatted.replaceAll(RegExp(r'[,\s]'), '');
  }
}
