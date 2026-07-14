import type { BaseWidgetConfig } from '@/widgets/widgetRegistry'

export interface CalendarConfig extends BaseWidgetConfig {
  showWeekends: boolean
}

export const defaultCalendarConfig: CalendarConfig = {
  showWeekends: true,
}

export function calendarConfigFromJson(json: Record<string, unknown>): CalendarConfig {
  return {
    showWeekends:
      typeof json.showWeekends === 'boolean'
        ? json.showWeekends
        : defaultCalendarConfig.showWeekends,
  }
}
