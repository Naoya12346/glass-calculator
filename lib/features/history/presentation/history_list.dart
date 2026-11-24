import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../settings/data/settings_provider.dart';
import '../data/history_provider.dart';
import '../domain/history_entry.dart';

class HistoryList extends ConsumerWidget {
  const HistoryList({
    required this.onReuse,
    super.key,
    this.padding = EdgeInsets.zero,
    this.scrollController,
  });

  final ValueChanged<String> onReuse;
  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final settings = ref.watch(settingsProvider);
    final strings = AppStrings(settings.state.language);
    final entries = history.filteredEntries;
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  onChanged: history.setQuery,
                  decoration: InputDecoration(
                    hintText: strings.searchHistory,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.pillRadius,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filledTonal(
                tooltip: strings.clearAll,
                onPressed: entries.isEmpty ? null : () => history.clear(),
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Text(
                strings.noHistory,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                controller: scrollController,
                shrinkWrap: scrollController != null,
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _HistoryTile(
                    entry: entry,
                    subtitle: dateFormat.format(entry.date),
                    onReuse: () => onReuse(entry.expression),
                    onCopy: () async {
                      await _copy(context, entry, strings.copied);
                    },
                    onShare: () => Share.share(
                      '${entry.expression} = ${entry.result}',
                    ),
                    onDelete: () => history.remove(entry.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, HistoryEntry entry, String message) async {
    await Clipboard.setData(
      ClipboardData(text: '${entry.expression} = ${entry.result}'),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({
    required this.entry,
    required this.subtitle,
    required this.onReuse,
    required this.onCopy,
    required this.onShare,
    required this.onDelete,
  });

  final HistoryEntry entry;
  final String subtitle;
  final VoidCallback onReuse;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(
      ref.watch(settingsProvider).state.language,
    );

    return Slidable(
      key: ValueKey<String>(entry.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.24,
        children: <Widget>[
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: strings.delete,
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.cardRadius),
        onTap: onReuse,
        title: Text(
          entry.expression,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              entry.result,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              tooltip: strings.copied,
              onPressed: onCopy,
              icon: const Icon(Icons.copy_all_outlined),
            ),
            IconButton(
              tooltip: 'Share',
              onPressed: onShare,
              icon: const Icon(Icons.ios_share),
            ),
          ],
        ),
      ),
    );
  }
}
