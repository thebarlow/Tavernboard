import { useProjects } from '@/hooks/useProjects'
import type { WidgetSettingsFormProps } from '@/widgets/widgetRegistry'
import type { TaskListConfig } from './config'

export function TaskListSettingsForm({ config, onChange }: WidgetSettingsFormProps<TaskListConfig>) {
  const { data: projects } = useProjects()

  return (
    <>
      <label className="flex items-center gap-2 text-sm text-text-primary">
        <input
          type="checkbox"
          checked={config.showCompleted}
          onChange={e => onChange({ ...config, showCompleted: e.target.checked })}
          className="accent-ember w-4 h-4"
        />
        Show completed tasks
      </label>
      <div>
        <p className="text-text-secondary text-xs mb-1">Filter by campaign</p>
        <select
          value={config.projectId ?? ''}
          onChange={e => onChange({ ...config, projectId: e.target.value || null })}
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        >
          <option value="">All campaigns</option>
          {(projects ?? []).map(p => (
            <option key={p.id} value={p.id}>{p.name}</option>
          ))}
        </select>
      </div>
    </>
  )
}
