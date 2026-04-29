import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import '../models/widget_config.dart';
import 'widget_slot.dart';

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key});

  static const _slots = [
    (typeKey: 'calendar', config: WidgetConfig(typeKey: 'calendar')),
    (typeKey: 'task_list', config: WidgetConfig(typeKey: 'task_list')),
    (typeKey: 'project_board', config: WidgetConfig(typeKey: 'project_board')),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1024 ? 3 : (width >= 600 ? 2 : 1);

    if (columns == 1) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _slots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) => SizedBox(
          height: 380,
          child: WidgetSlot(typeKey: _slots[i].typeKey, config: _slots[i].config),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutGrid(
        columnSizes: List.filled(columns, 1.fr),
        rowSizes: const [auto],
        rowGap: 16,
        columnGap: 16,
        children: _slots
            .map((slot) => SizedBox(
                  height: 380,
                  child: WidgetSlot(typeKey: slot.typeKey, config: slot.config),
                ))
            .toList(),
      ),
    );
  }
}
