import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_controller.dart';

final settingsProvider = ChangeNotifierProvider<SettingsController>((_) {
  return SettingsController();
});
