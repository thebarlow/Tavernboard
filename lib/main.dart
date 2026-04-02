import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/providers.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/projects_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'theme/tavern_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  await NotificationService.init();
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

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  Timer? _reminderTimer;

  static const _screens = <Widget>[
    CalendarScreen(),
    TodoScreen(),
    ProjectsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Check reminders every minute
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final entries = ref.read(entriesProvider).valueOrNull ?? [];
      NotificationService.checkAndFire(entries);
    });
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
