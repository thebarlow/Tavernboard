import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import TaskListWidget from '@/widgets/task-list'
import { defaultTaskListConfig } from '@/widgets/task-list/config'
import type { Entry } from '@/types/database'

const mockTask: Entry = {
  id: '1', user_id: 'u1', project_id: null,
  type: 'task', title: 'Buy milk', description: null,
  date: null, start_time: null, end_time: null,
  color_override: null, is_completed: false,
  reminder_time: null, recurrence_rule: null, created_at: '2026-01-01',
}

vi.mock('@/hooks/useEntries', () => ({
  useEntries: vi.fn(() => ({ data: [], isLoading: false, isError: false })),
  useCreateEntry: () => ({ mutateAsync: vi.fn(), isPending: false }),
  useUpdateEntry: () => ({ mutate: vi.fn(), mutateAsync: vi.fn(), isPending: false }),
  useDeleteEntry: () => ({ mutate: vi.fn(), isPending: false }),
}))

vi.mock('@/hooks/useProjects', () => ({
  useProjects: () => ({ data: [] }),
}))

describe('TaskListWidget', () => {
  it('shows "No tasks" when there are no entries', () => {
    render(<TaskListWidget config={defaultTaskListConfig} />)
    expect(screen.getByText('No tasks')).toBeInTheDocument()
  })

  it('shows loading skeleton when isLoading is true', async () => {
    const { useEntries } = await import('@/hooks/useEntries')
    vi.mocked(useEntries).mockReturnValueOnce(
      { data: undefined, isLoading: true, isError: false } as unknown as ReturnType<typeof useEntries>
    )
    const { container } = render(<TaskListWidget config={defaultTaskListConfig} />)
    expect(container.querySelector('.animate-pulse')).toBeInTheDocument()
  })

  it('shows error message when isError is true', async () => {
    const { useEntries } = await import('@/hooks/useEntries')
    vi.mocked(useEntries).mockReturnValueOnce(
      { data: undefined, isLoading: false, isError: true } as unknown as ReturnType<typeof useEntries>
    )
    render(<TaskListWidget config={defaultTaskListConfig} />)
    expect(screen.getByText('Could not load tasks')).toBeInTheDocument()
  })

  it('renders task titles', async () => {
    const { useEntries } = await import('@/hooks/useEntries')
    vi.mocked(useEntries).mockReturnValueOnce(
      { data: [mockTask], isLoading: false, isError: false } as unknown as ReturnType<typeof useEntries>
    )
    render(<TaskListWidget config={defaultTaskListConfig} />)
    expect(screen.getByText('Buy milk')).toBeInTheDocument()
  })

  it('hides completed tasks when showCompleted is false', async () => {
    const { useEntries } = await import('@/hooks/useEntries')
    vi.mocked(useEntries).mockReturnValueOnce(
      { data: [{ ...mockTask, is_completed: true }], isLoading: false, isError: false } as unknown as ReturnType<typeof useEntries>
    )
    render(<TaskListWidget config={{ ...defaultTaskListConfig, showCompleted: false }} />)
    expect(screen.queryByText('Buy milk')).not.toBeInTheDocument()
  })
})
