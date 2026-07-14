import { useState } from 'react'
import {
  useProjects,
  useCreateProject,
  useUpdateProject,
  useDeleteProject,
} from '@/hooks/useProjects'
import Dialog from '@/components/Dialog'
import WidgetSkeleton from '@/components/WidgetSkeleton'
import WidgetError from '@/components/WidgetError'
import type { Project } from '@/types/database'
import type { ProjectBoardConfig } from './config'

const SWATCH_COLORS = [
  '#C8860A', '#8B4513', '#5C3D1E', '#27AE60',
  '#2980B9', '#8E44AD', '#C0392B', '#F5E6C8',
]

interface Props { config: ProjectBoardConfig }

export default function ProjectBoardWidget({ config }: Props) {
  const { data: projects, isLoading, isError } = useProjects()
  const deleteProject = useDeleteProject()
  const [showCreate, setShowCreate] = useState(false)
  const [editProject, setEditProject] = useState<Project | null>(null)

  if (isLoading) return <WidgetSkeleton />
  if (isError) return <WidgetError message="Could not load campaigns" />

  const displayed = (projects ?? []).slice(0, config.maxProjects)

  return (
    <div className="flex flex-col h-full">
      {displayed.length === 0 ? (
        <p className="flex-1 flex items-center justify-center text-text-secondary text-sm">
          No campaigns yet
        </p>
      ) : (
        <ul className="flex-1 overflow-auto divide-y divide-divider">
          {displayed.map(project => (
            <li key={project.id} className="flex items-center gap-3 px-4 py-2">
              <div
                className="w-3 h-3 rounded-full shrink-0"
                style={{ backgroundColor: project.color }}
              />
              <div className="flex-1 min-w-0">
                <p className="text-text-primary text-sm truncate">{project.name}</p>
                {project.deadline && (
                  <p className="text-text-secondary text-xs">
                    Due {project.deadline.split('T')[0]}
                  </p>
                )}
              </div>
              <div className="flex gap-1 shrink-0">
                <button
                  onClick={() => setEditProject(project)}
                  onPointerDown={e => e.stopPropagation()}
                  className="text-text-secondary hover:text-parchment text-xs px-1"
                  aria-label="Edit campaign"
                >
                  ✎
                </button>
                <button
                  onClick={() => deleteProject.mutate(project.id)}
                  onPointerDown={e => e.stopPropagation()}
                  className="text-text-secondary hover:text-ember text-xs px-1"
                  aria-label="Delete campaign"
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
          + New Campaign
        </button>
      </div>

      {showCreate && <CreateProjectDialog onClose={() => setShowCreate(false)} />}
      {editProject && (
        <EditProjectDialog project={editProject} onClose={() => setEditProject(null)} />
      )}
    </div>
  )
}

function CreateProjectDialog({ onClose }: { onClose: () => void }) {
  const createProject = useCreateProject()
  const [name, setName] = useState('')
  const [color, setColor] = useState(SWATCH_COLORS[0])
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    if (!name.trim()) { setError('Name is required'); return }
    await createProject.mutateAsync({ name: name.trim(), color })
    onClose()
  }

  return (
    <Dialog title="New Campaign" onClose={onClose} onSave={handleSave} isSaving={createProject.isPending}>
      <div>
        <input
          value={name}
          onChange={e => { setName(e.target.value); setError(null) }}
          placeholder="Campaign name"
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        />
        {error && <p className="text-ember text-xs mt-1">{error}</p>}
      </div>
      <ColorPicker selected={color} onChange={setColor} />
    </Dialog>
  )
}

function EditProjectDialog({ project, onClose }: { project: Project; onClose: () => void }) {
  const updateProject = useUpdateProject()
  const [name, setName] = useState(project.name)
  const [color, setColor] = useState(project.color)
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    if (!name.trim()) { setError('Name is required'); return }
    await updateProject.mutateAsync({ id: project.id, updates: { name: name.trim(), color } })
    onClose()
  }

  return (
    <Dialog title="Edit Campaign" onClose={onClose} onSave={handleSave} isSaving={updateProject.isPending}>
      <div>
        <input
          value={name}
          onChange={e => { setName(e.target.value); setError(null) }}
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        />
        {error && <p className="text-ember text-xs mt-1">{error}</p>}
      </div>
      <ColorPicker selected={color} onChange={setColor} />
    </Dialog>
  )
}

function ColorPicker({ selected, onChange }: { selected: string; onChange: (c: string) => void }) {
  return (
    <div>
      <p className="text-text-secondary text-xs mb-2">Color</p>
      <div className="flex gap-2 flex-wrap">
        {SWATCH_COLORS.map(c => (
          <button
            key={c}
            onPointerDown={e => e.stopPropagation()}
            onClick={() => onChange(c)}
            className={`w-6 h-6 rounded-full border-2 transition-colors ${
              selected === c ? 'border-parchment-light' : 'border-transparent'
            }`}
            style={{ backgroundColor: c }}
            aria-label={c}
          />
        ))}
      </div>
    </div>
  )
}
