import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/number_text_formatter.dart';
import '../../../core/widgets/glass_container.dart';
import '../../settings/data/settings_provider.dart';

class ToolsPage extends ConsumerWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(ref.watch(settingsProvider).language);
    return DefaultTabController(
      length: 7,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(strings.tools, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const <Tab>[
                  Tab(text: 'EMI'),
                  Tab(text: 'GST'),
                  Tab(text: 'Discount'),
                  Tab(text: 'Percent'),
                  Tab(text: 'Age'),
                  Tab(text: 'BMI'),
                  Tab(text: 'Tip'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const SizedBox(
                height: 520,
                child: TabBarView(
                  children: <Widget>[
                    EmiCalculator(),
                    GstCalculator(),
                    DiscountCalculator(),
                    PercentageCalculator(),
                    AgeCalculator(),
                    BmiCalculator(),
                    TipSplitCalculator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class _ToolState<T extends ConsumerStatefulWidget> extends ConsumerState<T> {
  double number(TextEditingController controller, [double fallback = 0]) {
    return double.tryParse(controller.text.replaceAll(',', '')) ?? fallback;
  }

  String fmt(double value) {
    return NumberTextFormatter.format(value, ref.read(settingsProvider).state);
  }

  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget answer(BuildContext context, String label, String value) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmiCalculator extends ConsumerStatefulWidget {
  const EmiCalculator({super.key});

  @override
  ConsumerState<EmiCalculator> createState() => _EmiCalculatorState();
}

class _EmiCalculatorState extends _ToolState<EmiCalculator> {
  final principal = TextEditingController(text: '100000');
  final annualRate = TextEditingController(text: '8.5');
  final months = TextEditingController(text: '60');

  @override
  void initState() {
    super.initState();
    for (final controller in <TextEditingController>[
      principal,
      annualRate,
      months,
    ]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      principal,
      annualRate,
      months,
    ]) {
      controller.removeListener(_refresh);
      controller.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final p = number(principal);
    final r = number(annualRate) / 1200;
    final n = math.max(number(months, 1).round(), 1);
    final factor = math.pow(1 + r, n).toDouble();
    final emi = r == 0 ? p / n : p * r * factor / (factor - 1);
    final total = emi * n;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          field('Principal amount', principal),
          field('Annual interest rate (%)', annualRate),
          field('Tenure (months)', months),
          answer(context, 'Monthly EMI', fmt(emi)),
          const SizedBox(height: AppSpacing.sm),
          answer(context, 'Total payable', fmt(total)),
        ],
      ),
    );
  }
}

class GstCalculator extends ConsumerStatefulWidget {
  const GstCalculator({super.key});

  @override
  ConsumerState<GstCalculator> createState() => _GstCalculatorState();
}

class _GstCalculatorState extends _ToolState<GstCalculator> {
  final amount = TextEditingController(text: '1000');
  final rate = TextEditingController(text: '18');
  bool inclusive = false;

  @override
  void initState() {
    super.initState();
    amount.addListener(_refresh);
    rate.addListener(_refresh);
  }

  @override
  void dispose() {
    amount.removeListener(_refresh);
    rate.removeListener(_refresh);
    amount.dispose();
    rate.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final base = number(amount);
    final percent = number(rate);
    final net = inclusive ? base * 100 / (100 + percent) : base;
    final tax = net * percent / 100;
    final total = net + tax;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          field('Amount', amount),
          field('GST rate (%)', rate),
          SwitchListTile(
            title: const Text('Amount is GST inclusive'),
            value: inclusive,
            onChanged: (value) => setState(() => inclusive = value),
          ),
          answer(context, 'CGST + SGST', fmt(tax)),
          const SizedBox(height: AppSpacing.sm),
          answer(context, 'Total', fmt(total)),
        ],
      ),
    );
  }
}

class DiscountCalculator extends ConsumerStatefulWidget {
  const DiscountCalculator({super.key});

  @override
  ConsumerState<DiscountCalculator> createState() => _DiscountCalculatorState();
}

class _DiscountCalculatorState extends _ToolState<DiscountCalculator> {
  final price = TextEditingController(text: '999');
  final discount = TextEditingController(text: '20');

  @override
  void initState() {
    super.initState();
    price.addListener(_refresh);
    discount.addListener(_refresh);
  }

  @override
  void dispose() {
    price.removeListener(_refresh);
    discount.removeListener(_refresh);
    price.dispose();
    discount.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final original = number(price);
    final percent = number(discount);
    final saved = original * percent / 100;
    final finalPrice = original - saved;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          field('Original price', price),
          field('Discount (%)', discount),
          answer(context, 'You save', fmt(saved)),
          const SizedBox(height: AppSpacing.sm),
          answer(context, 'Final price', fmt(finalPrice)),
        ],
      ),
    );
  }
}

class PercentageCalculator extends ConsumerStatefulWidget {
  const PercentageCalculator({super.key});

  @override
  ConsumerState<PercentageCalculator> createState() => _PercentageCalculatorState();
}

class _PercentageCalculatorState extends _ToolState<PercentageCalculator> {
  final value = TextEditingController(text: '250');
  final percent = TextEditingController(text: '15');

  @override
  void initState() {
    super.initState();
    value.addListener(_refresh);
    percent.addListener(_refresh);
  }

  @override
  void dispose() {
    value.removeListener(_refresh);
    percent.removeListener(_refresh);
    value.dispose();
    percent.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final result = number(value) * number(percent) / 100;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          field('Value', value),
          field('Percent (%)', percent),
          answer(context, 'Result', fmt(result)),
        ],
      ),
    );
  }
}

class AgeCalculator extends ConsumerStatefulWidget {
  const AgeCalculator({super.key});

  @override
  ConsumerState<AgeCalculator> createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends _ToolState<AgeCalculator> {
  DateTime _birth = DateTime(2000, 1, 1);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays = now.difference(_birth).inDays;
    final years = totalDays ~/ 365;
    final remaining = totalDays % 365;
    final months = remaining ~/ 30;
    final days = remaining % 30;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ListTile(
            title: const Text('Date of birth'),
            subtitle: Text(_birth.toIso8601String().substring(0, 10)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _birth,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null && mounted) setState(() => _birth = picked);
            },
          ),
          answer(
            context,
            'Age',
            totalDays < 0
                ? 'Invalid date'
                : '$years years, $months months, $days days',
          ),
          const SizedBox(height: AppSpacing.sm),
          answer(context, 'Total days', totalDays < 0 ? '—' : '$totalDays'),
        ],
      ),
    );
  }
}

class BmiCalculator extends ConsumerStatefulWidget {
  const BmiCalculator({super.key});

  @override
  ConsumerState<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends _ToolState<BmiCalculator> {
  final weight = TextEditingController(text: '70');
  final height = TextEditingController(text: '175');

  @override
  void initState() {
    super.initState();
    weight.addListener(_refresh);
    height.addListener(_refresh);
  }

  @override
  void dispose() {
    weight.removeListener(_refresh);
    height.removeListener(_refresh);
    weight.dispose();
    height.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final kg = number(weight);
    final meters = number(height, 1) / 100;
    final bmi = kg / math.pow(meters, 2).toDouble();
    final category = bmi < 18.5
        ? 'Underweight'
        : bmi < 25
            ? 'Normal'
            : bmi < 30
                ? 'Overweight'
                : 'Obese';
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          field('Weight (kg)', weight),
          field('Height (cm)', height),
          answer(context, 'BMI', fmt(bmi)),
          const SizedBox(height: AppSpacing.sm),
          answer(context, 'Category', category),
        ],
      ),
    );
  }
}

class TipSplitCalculator extends ConsumerStatefulWidget {
  const TipSplitCalculator({super.key});

  @override
  ConsumerState<TipSplitCalculator> createState() => _TipSplitCalculatorState();
}

class _TipSplitCalculatorState extends _ToolState<TipSplitCalculator> {
  final bill = TextEditingController(text: '1200');
  final tip = TextEditingController(text: '10');
  final people = TextEditingController(text: '4');

  @override
  void initState() {
    super.initState();
    bill.addListener(_refresh);
    tip.addListener(_refresh);
    people.addListener(_refresh);
  }

  @override
  void dispose() {
    bill.removeListener(_refresh);
    tip.removeListener(_refresh);
    people.removeListener(_refresh);
    bill.dispose();
    tip.dispose();
    people.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final base = number(bill);
    final tipAmount = base * number(tip) / 100;
    final count = math.max(number(people, 1).round(), 1);
    final perPerson = (base + tipAmount) / count;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          field('Bill amount', bill),
          field('Tip (%)', tip),
          field('People', people),
          answer(context, 'Total with tip', fmt(base + tipAmount)),
          const SizedBox(height: AppSpacing.sm),
          answer(context, 'Per person', fmt(perPerson)),
        ],
      ),
    );
  }
}
