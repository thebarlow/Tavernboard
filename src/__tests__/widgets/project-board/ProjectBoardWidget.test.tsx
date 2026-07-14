import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import ProjectBoardWidget from '@/widgets/project-board'
import { defaultProjectBoardConfig } from '@/widgets/project-board/config'
import type { Project } from '@/types/database'

const mockProject: Project = {
  id: '1', user_id: 'u1', name: 'Short Film',
  color: '#C8860A', category_id: null, deadline: null, created_at: '2026-01-01',
}

vi.mock('@/hooks/useProjects', () => ({
  useProjects: vi.fn(() => ({ data: [], isLoading: false, isError: false })),
  useCreateProject: () => ({ mutateAsync: vi.fn(), isPending: false }),
  useUpdateProject: () => ({ mutateAsync: vi.fn(), isPending: false }),
  useDeleteProject: () => ({ mutate: vi.fn(), isPending: false }),
}))

describe('ProjectBoardWidget', () => {
  it('shows "No campaigns" when list is empty', () => {
    render(<ProjectBoardWidget config={defaultProjectBoardConfig} />)
    expect(screen.getByText('No campaigns yet')).toBeInTheDocument()
  })

  it('renders project names', async () => {
    const { useProjects } = await import('@/hooks/useProjects')
    vi.mocked(useProjects).mockReturnValueOnce(
      { data: [mockProject], isLoading: false, isError: false } as unknown as ReturnType<typeof useProjects>
    )
    render(<ProjectBoardWidget config={defaultProjectBoardConfig} />)
    expect(screen.getByText('Short Film')).toBeInTheDocument()
  })

  it('respects maxProjects limit', async () => {
    const { useProjects } = await import('@/hooks/useProjects')
    const many = Array.from({ length: 5 }, (_, i) => ({ ...mockProject, id: String(i), name: `Project ${i}` }))
    vi.mocked(useProjects).mockReturnValueOnce(
      { data: many, isLoading: false, isError: false } as unknown as ReturnType<typeof useProjects>
    )
    render(<ProjectBoardWidget config={{ maxProjects: 2 }} />)
    expect(screen.getAllByRole('listitem')).toHaveLength(2)
  })
})
