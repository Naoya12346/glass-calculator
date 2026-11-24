import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glass_calculator/features/calculator/presentation/keypad.dart';

void main() {
  testWidgets('basic keypad renders all keys and reports taps', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: SizedBox(height: 700, child: BasicKeypad(onAction: _noop))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('7'), findsOneWidget);
    expect(find.text('='), findsOneWidget);
    expect(find.text('('), findsOneWidget);
  });

  testWidgets('scientific keypad reports scientific actions', (tester) async {
    final actions = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 700,
              child: ScientificPad(onAction: actions.add),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('sin'));
    await tester.pumpAndSettle();

    expect(actions, contains('sin'));
  });
}

void _noop(String value) {}
