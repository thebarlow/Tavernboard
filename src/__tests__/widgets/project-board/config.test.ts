import { describe, it, expect } from 'vitest'
import { projectBoardConfigFromJson, defaultProjectBoardConfig } from '@/widgets/project-board/config'

describe('projectBoardConfigFromJson', () => {
  it('returns defaults for empty input', () => {
    expect(projectBoardConfigFromJson({})).toEqual(defaultProjectBoardConfig)
  })

  it('overrides maxProjects', () => {
    expect(projectBoardConfigFromJson({ maxProjects: 5 }).maxProjects).toBe(5)
  })

  it('ignores non-number maxProjects', () => {
    expect(projectBoardConfigFromJson({ maxProjects: 'all' }).maxProjects)
      .toBe(defaultProjectBoardConfig.maxProjects)
  })

  it('clamps maxProjects to minimum of 1', () => {
    expect(projectBoardConfigFromJson({ maxProjects: 0 }).maxProjects).toBe(1)
  })
})
