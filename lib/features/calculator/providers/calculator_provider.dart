import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/expression_controller.dart';

final expressionProvider = ChangeNotifierProvider<ExpressionController>((_) {
  return ExpressionController();
});
