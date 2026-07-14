import type { WidgetMeta } from '@/widgets/widgetRegistry'
import { defaultProjectBoardConfig, projectBoardConfigFromJson, type ProjectBoardConfig } from './config'

export const projectBoardMeta: WidgetMeta<ProjectBoardConfig> = {
  typeKey: 'project_board',
  displayName: 'Campaigns',
  icon: '🏰',
  defaultConfig: defaultProjectBoardConfig,
  configFromJson: projectBoardConfigFromJson,
}
