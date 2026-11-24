import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_durations.dart';
import 'core/constants/app_strings.dart';
import 'core/widgets/animated_background.dart';
import 'features/calculator/presentation/calculator_page.dart';
import 'features/converter/presentation/converter_page.dart';
import 'features/extras/presentation/tools_page.dart';
import 'features/history/data/history_provider.dart';
import 'features/history/presentation/history_page.dart';
import 'features/settings/data/settings_provider.dart';
import 'features/settings/presentation/settings_page.dart';

class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});

  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(settingsProvider).load();
      ref.read(historyProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final strings = AppStrings(settings.language);

    final pages = <Widget>[
      const CalculatorPage(),
      const ConverterPage(),
      const ToolsPage(),
      const HistoryPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const AnimatedBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppDurations.normal,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_index),
                      child: pages[_index],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewPadding.bottom,
                  ),
                  child: NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: (index) {
                      setState(() => _index = index);
                    },
                    destinations: <NavigationDestination>[
                      NavigationDestination(
                        icon: const Icon(Icons.calculate_outlined),
                        selectedIcon: const Icon(Icons.calculate),
                        label: strings.calculator,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.swap_horiz_outlined),
                        selectedIcon: const Icon(Icons.swap_horiz),
                        label: strings.converter,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.construction_outlined),
                        selectedIcon: const Icon(Icons.construction),
                        label: strings.tools,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.history_outlined),
                        selectedIcon: const Icon(Icons.history),
                        label: strings.history,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.settings_outlined),
                        selectedIcon: const Icon(Icons.settings),
                        label: strings.settings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
