import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../core/utils/number_text_formatter.dart';
import '../../../core/widgets/glass_container.dart';
import '../../settings/data/settings_provider.dart';
import '../data/converter_catalog.dart';
import '../data/converter_engine.dart';

class ConverterPage extends ConsumerStatefulWidget {
  const ConverterPage({super.key});

  @override
  ConsumerState<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends ConsumerState<ConverterPage> {
  int _categoryIndex = 0;
  String _from = 'm';
  String _to = 'km';
  final TextEditingController _input = TextEditingController(text: '1');

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final strings = AppStrings(settings.state.language);
    final category = ConverterCatalog.categories[_categoryIndex];
    final value = double.tryParse(_input.text.replaceAll(',', '')) ?? 0;
    final converted = ConverterEngine.convert(
      value: value,
      category: category,
      fromId: _from,
      toId: _to,
    );
    final formatted = NumberTextFormatter.format(converted, settings.state);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(strings.converter, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ConverterCatalog.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = ConverterCatalog.categories[index];
                  return ChoiceChip(
                    avatar: Icon(item.icon, size: 18),
                    label: Text(item.label),
                    selected: index == _categoryIndex,
                    onSelected: (_) {
                      FeedbackService.tap(ref);
                      setState(() {
                        _categoryIndex = index;
                        _from = item.units.first.id;
                        _to = item.units.length > 1
                            ? item.units[1].id
                            : item.units.first.id;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassContainer(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _input,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    decoration: InputDecoration(
                      labelText: strings.enterValue,
                      suffixText: category.unit(_from).symbol,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 560;
                      final selector = <Widget>[
                        Expanded(
                          child: _UnitSelector(
                            label: strings.from,
                            units: category.units,
                            value: _from,
                            onChanged: (value) => setState(() => _from = value),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: strings.swap,
                          onPressed: () {
                            setState(() {
                              final temp = _from;
                              _from = _to;
                              _to = temp;
                            });
                          },
                          icon: const Icon(Icons.swap_horiz),
                        ),
                        Expanded(
                          child: _UnitSelector(
                            label: strings.to,
                            units: category.units,
                            value: _to,
                            onChanged: (value) => setState(() => _to = value),
                          ),
                        ),
                      ];
                      return wide
                          ? Row(children: selector)
                          : Column(children: selector);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: <Widget>[
                  Text(strings.result, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$formatted ${category.unit(_to).symbol}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: settings.state.accent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({
    required this.label,
    required this.units,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<UnitDefinition> units;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: <DropdownMenuItem<String>>[
        for (final unit in units)
          DropdownMenuItem<String>(
            value: unit.id,
            child: Text('${unit.symbol} · ${unit.label}'),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}
