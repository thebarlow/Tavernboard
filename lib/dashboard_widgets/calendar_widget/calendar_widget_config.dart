import '../../models/widget_config.dart';

class CalendarWidgetConfig {
  final bool showWeekends;

  const CalendarWidgetConfig({this.showWeekends = true});

  factory CalendarWidgetConfig.fromWidgetConfig(WidgetConfig config) {
    return CalendarWidgetConfig(
      showWeekends: config.settings['show_weekends'] as bool? ?? true,
    );
  }
}
