import '../../models/widget_config.dart';

class TaskListWidgetConfig {
  final bool showCompleted;
  final String? projectFilter;

  const TaskListWidgetConfig({
    this.showCompleted = true,
    this.projectFilter,
  });

  factory TaskListWidgetConfig.fromWidgetConfig(WidgetConfig config) {
    return TaskListWidgetConfig(
      showCompleted: config.settings['show_completed'] as bool? ?? true,
      projectFilter: config.settings['project_filter'] as String?,
    );
  }
}
