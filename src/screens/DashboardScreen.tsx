import { useState, useCallback, useRef } from 'react'
import GridLayout, { WidthProvider, type Layout } from 'react-grid-layout'
import 'react-grid-layout/css/styles.css'
import 'react-resizable/css/styles.css'
import { useAuth } from '@/contexts/AuthContext'
import {
  useDashboardLayout,
  useRemoveWidget,
  useUpdateWidgetLayout,
  type DashboardWidget,
} from '@/hooks/useDashboardLayout'
import { widgetRegistry } from '@/widgets/widgetRegistry'
import WidgetFrame from '@/components/WidgetFrame'
import WidgetSkeleton from '@/components/WidgetSkeleton'
import AddWidgetDialog from '@/components/AddWidgetDialog'
import WidgetSettingsDialog from '@/components/WidgetSettingsDialog'

const ResponsiveGrid = WidthProvider(GridLayout)
const DEBOUNCE_MS = 800

export default function DashboardScreen() {
  const { signOut } = useAuth()
  const { data: widgets, isLoading } = useDashboardLayout()
  const removeWidget = useRemoveWidget()
  const updateLayout = useUpdateWidgetLayout()
  const [showAdd, setShowAdd] = useState(false)
  const [settingsWidget, setSettingsWidget] = useState<DashboardWidget | null>(null)
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const handleLayoutChange = useCallback(
    (layout: Layout[]) => {
      if (debounceRef.current) clearTimeout(debounceRef.current)
      debounceRef.current = setTimeout(() => {
        updateLayout.mutate(
          layout.map(item => ({
            id: item.i,
            posX: item.x,
            posY: item.y,
            width: item.w,
            height: item.h,
          }))
        )
      }, DEBOUNCE_MS)
    },
    [updateLayout]
  )

  const layout: Layout[] = (widgets ?? []).map(w => ({
    i: w.id,
    x: w.posX,
    y: w.posY,
    w: w.width,
    h: w.height,
  }))

  return (
    <div className="min-h-screen bg-background">
      <header className="flex items-center justify-between px-6 py-4 border-b border-divider">
        <h1 className="font-display text-xl text-parchment">Tavernboard</h1>
        <div className="flex items-center gap-3">
          <button
            onClick={() => setShowAdd(true)}
            className="bg-ember hover:bg-ember-light text-parchment-light font-display text-sm px-4 py-2 rounded transition-colors"
          >
            + Add Widget
          </button>
          <button
            onClick={() => signOut()}
            className="text-text-secondary hover:text-parchment text-sm transition-colors"
          >
            Sign Out
          </button>
        </div>
      </header>

      <main className="p-4">
        {isLoading ? (
          <div className="grid grid-cols-3 gap-4">
            {[1, 2, 3].map(i => (
              <div key={i} className="h-80">
                <WidgetSkeleton />
              </div>
            ))}
          </div>
        ) : (widgets ?? []).length === 0 ? (
          <div className="flex flex-col items-center justify-center h-96 text-text-secondary gap-4">
            <p>Your board is empty.</p>
            <button
              onClick={() => setShowAdd(true)}
              className="text-parchment hover:text-parchment-light underline"
            >
              Add a widget
            </button>
          </div>
        ) : (
          <ResponsiveGrid
            layout={layout}
            cols={12}
            rowHeight={40}
            onLayoutChange={handleLayoutChange}
            draggableHandle=".widget-drag-handle"
            draggableCancel=".widget-action"
          >
            {(widgets ?? []).map(w => {
              const def = widgetRegistry[w.typeKey]
              if (!def) return <div key={w.id} />
              const config = def.meta.configFromJson(w.settings)
              return (
                <div key={w.id}>
                  <WidgetFrame
                    title={def.meta.displayName}
                    onRemove={() => removeWidget.mutate(w.id)}
                    onSettings={def.SettingsForm ? () => setSettingsWidget(w) : undefined}
                  >
                    <def.Component config={config} />
                  </WidgetFrame>
                </div>
              )
            })}
          </ResponsiveGrid>
        )}
      </main>

      {showAdd && <AddWidgetDialog onClose={() => setShowAdd(false)} />}
      {settingsWidget && widgetRegistry[settingsWidget.typeKey] && (
        <WidgetSettingsDialog
          widget={settingsWidget}
          definition={widgetRegistry[settingsWidget.typeKey]}
          onClose={() => setSettingsWidget(null)}
        />
      )}
    </div>
  )
}
