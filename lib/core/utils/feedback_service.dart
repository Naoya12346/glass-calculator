import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/data/settings_provider.dart';

class FeedbackService {
  const FeedbackService._();

  static void tap(WidgetRef ref, {bool strong = false}) {
    final settings = ref.read(settingsProvider);
    if (!settings.state.haptics) return;
    if (strong) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  static void error(WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    if (!settings.state.haptics) return;
    HapticFeedback.heavyImpact();
  }
}
