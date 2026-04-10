import 'package:flutter/material.dart';
import '../models/widget_config.dart';
import '../widgets/tavern_card.dart';
import 'widget_registry.dart';

class WidgetSlot extends StatelessWidget {
  final String typeKey;
  final WidgetConfig config;

  const WidgetSlot({
    super.key,
    required this.typeKey,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return TavernCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WidgetRegistry.build(typeKey, config),
      ),
    );
  }
}
