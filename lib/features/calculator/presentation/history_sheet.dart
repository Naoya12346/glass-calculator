import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../calculator/providers/calculator_provider.dart';
import '../../settings/data/settings_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/glass_container.dart';
import 'history_list.dart';

Future<void> showHistorySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.35,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, _) {
              final strings = AppStrings(ref.watch(settingsProvider).language);
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: GlassContainer(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.24),
                          borderRadius: AppSpacing.pillRadius,
                        ),
                      ),
                      Text(
                        strings.history,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Flexible(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: HistoryList(
                            padding: EdgeInsets.zero,
                            scrollController: scrollController,
                            onReuse: (expression) {
                              ref
                                  .read(expressionProvider)
                                  .setExpression(expression);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
