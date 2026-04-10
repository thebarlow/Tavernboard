import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/tavern_theme.dart';

class TavernboardApp extends ConsumerWidget {
  const TavernboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Tavernboard',
      theme: TavernTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
