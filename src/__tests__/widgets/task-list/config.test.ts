import { describe, it, expect } from 'vitest'
import { taskListConfigFromJson, defaultTaskListConfig } from '@/widgets/task-list/config'

describe('taskListConfigFromJson', () => {
  it('returns defaults for empty input', () => {
    expect(taskListConfigFromJson({})).toEqual(defaultTaskListConfig)
  })

  it('overrides showCompleted', () => {
    expect(taskListConfigFromJson({ showCompleted: false }).showCompleted).toBe(false)
  })

  it('overrides projectId', () => {
    expect(taskListConfigFromJson({ projectId: 'abc' }).projectId).toBe('abc')
  })

  it('ignores non-boolean showCompleted', () => {
    expect(taskListConfigFromJson({ showCompleted: 'yes' }).showCompleted).toBe(true)
  })

  it('ignores non-string projectId', () => {
    expect(taskListConfigFromJson({ projectId: 123 }).projectId).toBeNull()
  })
})
