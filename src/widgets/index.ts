import { registerWidget } from './widgetRegistry'
import { taskListMeta } from './task-list/meta'
import TaskListWidget from './task-list'
import { TaskListSettingsForm } from './task-list/settings'
import { calendarMeta } from './calendar/meta'
import CalendarWidget from './calendar'
import { projectBoardMeta } from './project-board/meta'
import ProjectBoardWidget from './project-board'

registerWidget({ meta: taskListMeta, Component: TaskListWidget, SettingsForm: TaskListSettingsForm })
registerWidget({ meta: calendarMeta, Component: CalendarWidget })
registerWidget({ meta: projectBoardMeta, Component: ProjectBoardWidget })
