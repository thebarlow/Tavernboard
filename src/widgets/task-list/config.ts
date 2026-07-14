import type { BaseWidgetConfig } from '@/widgets/widgetRegistry'

export interface TaskListConfig extends BaseWidgetConfig {
  showCompleted: boolean
  projectId: string | null
}

export const defaultTaskListConfig: TaskListConfig = {
  showCompleted: true,
  projectId: null,
}

export function taskListConfigFromJson(json: Record<string, unknown>): TaskListConfig {
  return {
    showCompleted:
      typeof json.showCompleted === 'boolean'
        ? json.showCompleted
        : defaultTaskListConfig.showCompleted,
    projectId:
      typeof json.projectId === 'string'
        ? json.projectId
        : defaultTaskListConfig.projectId,
  }
}
