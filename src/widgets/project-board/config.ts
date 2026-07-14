import type { BaseWidgetConfig } from '@/widgets/widgetRegistry'

export interface ProjectBoardConfig extends BaseWidgetConfig {
  maxProjects: number
}

export const defaultProjectBoardConfig: ProjectBoardConfig = {
  maxProjects: 10,
}

export function projectBoardConfigFromJson(json: Record<string, unknown>): ProjectBoardConfig {
  const raw = json.maxProjects
  const maxProjects =
    typeof raw === 'number'
      ? Math.max(1, Math.floor(raw))
      : defaultProjectBoardConfig.maxProjects
  return { maxProjects }
}
