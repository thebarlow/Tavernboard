import { widgetRegistry } from '@/widgets/widgetRegistry'
import { useAddWidget } from '@/hooks/useDashboardLayout'

interface Props { onClose: () => void }

export default function AddWidgetDialog({ onClose }: Props) {
  const addWidget = useAddWidget()

  const handleAdd = async (typeKey: string) => {
    const def = widgetRegistry[typeKey]
    if (!def) return
    await addWidget.mutateAsync({
      typeKey,
      settings: def.meta.defaultConfig as Record<string, unknown>,
    })
    onClose()
  }

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-surface border border-divider rounded-lg w-full max-w-sm p-6">
        <h3 className="font-display text-parchment mb-4">Add Widget</h3>
        <div className="space-y-2">
          {Object.values(widgetRegistry).map(def => (
            <button
              key={def.meta.typeKey}
              onClick={() => handleAdd(def.meta.typeKey)}
              disabled={addWidget.isPending}
              className="w-full flex items-center gap-3 p-3 border border-divider rounded hover:border-parchment text-left transition-colors disabled:opacity-50"
            >
              <span className="text-xl">{def.meta.icon}</span>
              <span className="text-text-primary text-sm">{def.meta.displayName}</span>
            </button>
          ))}
        </div>
        <button
          onClick={onClose}
          className="w-full mt-4 border border-divider text-text-secondary py-2 rounded text-sm hover:border-parchment transition-colors"
        >
          Cancel
        </button>
      </div>
    </div>
  )
}
