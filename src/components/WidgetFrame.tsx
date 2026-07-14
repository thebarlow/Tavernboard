interface WidgetFrameProps {
  title: string
  onRemove: () => void
  onSettings?: () => void
  children: React.ReactNode
}

export default function WidgetFrame({ title, onRemove, onSettings, children }: WidgetFrameProps) {
  return (
    <div className="h-full flex flex-col bg-surface rounded-lg border border-divider overflow-hidden">
      <div className="widget-drag-handle flex items-center justify-between px-4 py-3 border-b border-divider shrink-0 cursor-grab active:cursor-grabbing">
        <h2 className="font-display text-sm text-parchment select-none">{title}</h2>
        <div className="flex items-center gap-2">
          {onSettings && (
            <button
              onClick={onSettings}
              className="widget-action text-text-secondary hover:text-parchment text-sm leading-none transition-colors"
              aria-label="Widget settings"
            >
              ⚙
            </button>
          )}
          <button
            onClick={onRemove}
            className="widget-action text-text-secondary hover:text-ember text-lg leading-none transition-colors"
            aria-label="Remove widget"
          >
            ×
          </button>
        </div>
      </div>
      <div className="flex-1 overflow-auto min-h-0">
        {children}
      </div>
    </div>
  )
}
