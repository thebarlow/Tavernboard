import type { WidgetMeta } from '@/widgets/widgetRegistry'
import { defaultTaskListConfig, taskListConfigFromJson, type TaskListConfig } from './config'

export const taskListMeta: WidgetMeta<TaskListConfig> = {
  typeKey: 'task_list',
  displayName: 'Task List',
  icon: '☑',
  defaultConfig: defaultTaskListConfig,
  configFromJson: taskListConfigFromJson,
}
