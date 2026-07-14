import type React from 'react'

// BaseWidgetConfig is intentionally empty — a hook for future shared settings.
// Size and position are layout concerns stored as columns in dashboard_widgets,
// not as widget settings.
export interface BaseWidgetConfig {}

export interface WidgetMeta<C extends BaseWidgetConfig = BaseWidgetConfig> {
  typeKey: string
  displayName: string
  icon: string
  defaultConfig: C
  configFromJson: (json: Record<string, unknown>) => C
}

export interface WidgetSettingsFormProps<C extends BaseWidgetConfig = BaseWidgetConfig> {
  config: C
  onChange: (next: C) => void
}

export interface WidgetDefinition<C extends BaseWidgetConfig = BaseWidgetConfig> {
  meta: WidgetMeta<C>
  Component: React.FC<{ config: C }>
  SettingsForm?: React.FC<WidgetSettingsFormProps<C>>
}

export const widgetRegistry: Record<string, WidgetDefinition> = {}

export function registerWidget<C extends BaseWidgetConfig>(
  definition: WidgetDefinition<C>
): void {
  widgetRegistry[definition.meta.typeKey] = definition as unknown as WidgetDefinition
}
