import { describe, it, expect } from 'vitest'
import { calendarConfigFromJson, defaultCalendarConfig } from '@/widgets/calendar/config'

describe('calendarConfigFromJson', () => {
  it('returns defaults for empty input', () => {
    expect(calendarConfigFromJson({})).toEqual(defaultCalendarConfig)
  })

  it('overrides showWeekends', () => {
    expect(calendarConfigFromJson({ showWeekends: false }).showWeekends).toBe(false)
  })

  it('ignores non-boolean showWeekends', () => {
    expect(calendarConfigFromJson({ showWeekends: 'true' }).showWeekends).toBe(true)
  })
})
