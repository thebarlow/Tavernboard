import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/providers.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/projects_screen.dart';
import 'theme/tavern_theme.dart';

void main() {
  runApp(const ProviderScope(child: TavernboardApp()));
}

class TavernboardApp extends StatelessWidget {
  const TavernboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tavernboard',
      debugShowCheckedModeBanner: false,
      theme: TavernTheme.build(),
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = <Widget>[
    CalendarScreen(),
    TodoScreen(),
    ProjectsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      body: _screens[selectedTab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (i) {
          ref.read(selectedTabProvider.notifier).state = i;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Chronicle',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Quest Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Campaigns',
          ),
        ],
      ),
    );
  }
}
