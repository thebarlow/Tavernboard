import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'dashboard_widgets/calendar_widget/calendar_widget.dart';
import 'dashboard_widgets/project_board_widget/project_board_widget.dart';
import 'dashboard_widgets/task_list_widget/task_list_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  CalendarWidget.register();
  TaskListWidget.register();
  ProjectBoardWidget.register();
  runApp(const ProviderScope(child: TavernboardApp()));
}
