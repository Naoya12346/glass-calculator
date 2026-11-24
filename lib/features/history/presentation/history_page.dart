import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/glass_container.dart';
import '../../calculator/providers/calculator_provider.dart';
import '../../settings/data/settings_provider.dart';
import 'history_list.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(ref.watch(settingsProvider).language);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(strings.history, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: GlassContainer(
              child: HistoryList(
                onReuse: (expression) {
                  ref.read(expressionProvider).setExpression(expression);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(expression)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
