import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/widget_config.dart';
import '../theme/tavern_theme.dart';

abstract class BaseWidget extends ConsumerWidget {
  final WidgetConfig config;

  const BaseWidget({super.key, required this.config});

  String get widgetTitle;

  Widget buildContent(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: TavernColors.divider)),
          ),
          child: Text(
            widgetTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(child: buildContent(context, ref)),
      ],
    );
  }
}
