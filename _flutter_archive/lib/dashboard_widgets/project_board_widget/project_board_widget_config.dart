import '../../models/widget_config.dart';

class ProjectBoardWidgetConfig {
  final int maxProjects;

  const ProjectBoardWidgetConfig({this.maxProjects = 10});

  factory ProjectBoardWidgetConfig.fromWidgetConfig(WidgetConfig config) {
    return ProjectBoardWidgetConfig(
      maxProjects: config.settings['max_projects'] as int? ?? 10,
    );
  }
}
