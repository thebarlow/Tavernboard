interface DialogProps {
  title: string
  children: React.ReactNode
  onClose: () => void
  onSave: () => void
  isSaving: boolean
}

export default function Dialog({ title, children, onClose, onSave, isSaving }: DialogProps) {
  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-surface border border-divider rounded-lg w-full max-w-sm p-6">
        <h3 className="font-display text-parchment mb-4">{title}</h3>
        <div className="space-y-3">{children}</div>
        <div className="flex gap-3 mt-4">
          <button
            onClick={onClose}
            className="flex-1 border border-divider text-text-secondary py-2 rounded text-sm hover:border-parchment transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={onSave}
            disabled={isSaving}
            className="flex-1 bg-ember text-parchment-light py-2 rounded text-sm disabled:opacity-50 hover:bg-ember-light transition-colors"
          >
            {isSaving ? '...' : 'Save'}
          </button>
        </div>
      </div>
    </div>
  )
}
