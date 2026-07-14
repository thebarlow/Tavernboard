import { useState } from 'react'
import Dialog from '@/components/Dialog'
import { useUpdateWidgetSettings, type DashboardWidget } from '@/hooks/useDashboardLayout'
import type { BaseWidgetConfig, WidgetDefinition } from '@/widgets/widgetRegistry'

interface Props {
  widget: DashboardWidget
  definition: WidgetDefinition
  onClose: () => void
}

export default function WidgetSettingsDialog({ widget, definition, onClose }: Props) {
  const updateSettings = useUpdateWidgetSettings()
  const [draft, setDraft] = useState<BaseWidgetConfig>(() =>
    definition.meta.configFromJson(widget.settings)
  )

  const handleSave = async () => {
    await updateSettings.mutateAsync({
      id: widget.id,
      settings: draft as Record<string, unknown>,
    })
    onClose()
  }

  const SettingsForm = definition.SettingsForm
  if (!SettingsForm) return null

  return (
    <Dialog
      title={`${definition.meta.displayName} Settings`}
      onClose={onClose}
      onSave={handleSave}
      isSaving={updateSettings.isPending}
    >
      <SettingsForm config={draft} onChange={setDraft} />
    </Dialog>
  )
}
