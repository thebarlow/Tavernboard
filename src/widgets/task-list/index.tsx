import { useState } from 'react'
import {
  useEntries,
  useCreateEntry,
  useUpdateEntry,
  useDeleteEntry,
} from '@/hooks/useEntries'
import { useProjects } from '@/hooks/useProjects'
import Dialog from '@/components/Dialog'
import WidgetSkeleton from '@/components/WidgetSkeleton'
import WidgetError from '@/components/WidgetError'
import type { Entry } from '@/types/database'
import type { TaskListConfig } from './config'

interface Props { config: TaskListConfig }

export default function TaskListWidget({ config }: Props) {
  const { data: entries, isLoading, isError } = useEntries()
  const updateEntry = useUpdateEntry()
  const deleteEntry = useDeleteEntry()
  const [showCreate, setShowCreate] = useState(false)
  const [editEntry, setEditEntry] = useState<Entry | null>(null)

  if (isLoading) return <WidgetSkeleton />
  if (isError) return <WidgetError message="Could not load tasks" />

  const tasks = (entries ?? []).filter(e => {
    if (e.type !== 'task') return false
    if (!config.showCompleted && e.is_completed) return false
    if (config.projectId && e.project_id !== config.projectId) return false
    return true
  })

  return (
    <div className="flex flex-col h-full">
      {tasks.length === 0 ? (
        <p className="flex-1 flex items-center justify-center text-text-secondary text-sm">
          No tasks
        </p>
      ) : (
        <ul className="flex-1 overflow-auto divide-y divide-divider">
          {tasks.map(task => (
            <li key={task.id} className="flex items-center gap-3 px-4 py-2">
              <input
                type="checkbox"
                checked={task.is_completed}
                onChange={() =>
                  updateEntry.mutate({
                    id: task.id,
                    updates: { is_completed: !task.is_completed },
                  })
                }
                className="accent-ember w-4 h-4 shrink-0"
              />
              <span
                className={`flex-1 text-sm ${
                  task.is_completed
                    ? 'line-through text-text-secondary'
                    : 'text-text-primary'
                }`}
              >
                {task.title}
              </span>
              <div className="flex gap-1 shrink-0">
                <button
                  onClick={() => setEditEntry(task)}
                  onPointerDown={e => e.stopPropagation()}
                  className="text-text-secondary hover:text-parchment text-xs px-1"
                  aria-label="Edit task"
                >
                  ✎
                </button>
                <button
                  onClick={() => deleteEntry.mutate(task.id)}
                  onPointerDown={e => e.stopPropagation()}
                  className="text-text-secondary hover:text-ember text-xs px-1"
                  aria-label="Delete task"
                >
                  ×
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}

      <div className="border-t border-divider p-2 shrink-0">
        <button
          onClick={() => setShowCreate(true)}
          onPointerDown={e => e.stopPropagation()}
          className="w-full text-center text-parchment text-sm py-1 hover:text-parchment-light transition-colors"
        >
          + New Task
        </button>
      </div>

      {showCreate && <CreateTaskDialog onClose={() => setShowCreate(false)} />}
      {editEntry && (
        <EditTaskDialog entry={editEntry} onClose={() => setEditEntry(null)} />
      )}
    </div>
  )
}

function CreateTaskDialog({ onClose }: { onClose: () => void }) {
  const { data: projects } = useProjects()
  const createEntry = useCreateEntry()
  const [title, setTitle] = useState('')
  const [projectId, setProjectId] = useState('')
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    if (!title.trim()) { setError('Title is required'); return }
    await createEntry.mutateAsync({
      type: 'task',
      title: title.trim(),
      project_id: projectId || null,
      is_completed: false,
      description: null,
      date: null,
      start_time: null,
      end_time: null,
      color_override: null,
      reminder_time: null,
      recurrence_rule: null,
    })
    onClose()
  }

  return (
    <Dialog title="New Task" onClose={onClose} onSave={handleSave} isSaving={createEntry.isPending}>
      <div>
        <input
          value={title}
          onChange={e => { setTitle(e.target.value); setError(null) }}
          placeholder="Task title"
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        />
        {error && <p className="text-ember text-xs mt-1">{error}</p>}
      </div>
      <select
        value={projectId}
        onChange={e => setProjectId(e.target.value)}
        className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
      >
        <option value="">No campaign</option>
        {(projects ?? []).map(p => (
          <option key={p.id} value={p.id}>{p.name}</option>
        ))}
      </select>
    </Dialog>
  )
}

function EditTaskDialog({ entry, onClose }: { entry: Entry; onClose: () => void }) {
  const { data: projects } = useProjects()
  const updateEntry = useUpdateEntry()
  const [title, setTitle] = useState(entry.title)
  const [projectId, setProjectId] = useState(entry.project_id ?? '')
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    if (!title.trim()) { setError('Title is required'); return }
    await updateEntry.mutateAsync({
      id: entry.id,
      updates: { title: title.trim(), project_id: projectId || null },
    })
    onClose()
  }

  return (
    <Dialog title="Edit Task" onClose={onClose} onSave={handleSave} isSaving={updateEntry.isPending}>
      <div>
        <input
          value={title}
          onChange={e => { setTitle(e.target.value); setError(null) }}
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        />
        {error && <p className="text-ember text-xs mt-1">{error}</p>}
      </div>
      <select
        value={projectId}
        onChange={e => setProjectId(e.target.value)}
        className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
      >
        <option value="">No campaign</option>
        {(projects ?? []).map(p => (
          <option key={p.id} value={p.id}>{p.name}</option>
        ))}
      </select>
    </Dialog>
  )
}
