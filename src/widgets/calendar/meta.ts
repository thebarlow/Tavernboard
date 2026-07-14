import type { WidgetMeta } from '@/widgets/widgetRegistry'
import { defaultCalendarConfig, calendarConfigFromJson, type CalendarConfig } from './config'

export const calendarMeta: WidgetMeta<CalendarConfig> = {
  typeKey: 'calendar',
  displayName: 'Calendar',
  icon: '📅',
  defaultConfig: defaultCalendarConfig,
  configFromJson: calendarConfigFromJson,
}
