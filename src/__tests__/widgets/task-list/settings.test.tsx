import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import { TaskListSettingsForm } from '@/widgets/task-list/settings'
import { defaultTaskListConfig } from '@/widgets/task-list/config'

vi.mock('@/hooks/useProjects', () => ({
  useProjects: () => ({ data: [{ id: 'p1', name: 'Short Film', color: '#C8860A', user_id: 'u1', category_id: null, deadline: null, created_at: '2026-01-01' }] }),
}))

describe('TaskListSettingsForm', () => {
  it('renders current config values', () => {
    render(<TaskListSettingsForm config={defaultTaskListConfig} onChange={() => {}} />)
    expect(screen.getByRole('checkbox')).toBeChecked()
    expect(screen.getByRole('combobox')).toHaveValue('')
  })

  it('emits updated config when showCompleted toggled', () => {
    const onChange = vi.fn()
    render(<TaskListSettingsForm config={defaultTaskListConfig} onChange={onChange} />)
    fireEvent.click(screen.getByRole('checkbox'))
    expect(onChange).toHaveBeenCalledWith({ ...defaultTaskListConfig, showCompleted: false })
  })

  it('emits updated config when campaign selected', () => {
    const onChange = vi.fn()
    render(<TaskListSettingsForm config={defaultTaskListConfig} onChange={onChange} />)
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'p1' } })
    expect(onChange).toHaveBeenCalledWith({ ...defaultTaskListConfig, projectId: 'p1' })
  })
})
