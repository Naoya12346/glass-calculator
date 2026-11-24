import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'history_controller.dart';

final historyProvider = ChangeNotifierProvider<HistoryController>((_) {
  return HistoryController();
});
