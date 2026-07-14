import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import type { DashboardWidgetRow } from '@/types/database'

export const DASHBOARD_KEY = ['dashboard_widgets'] as const

export interface DashboardWidget {
  id: string
  typeKey: string
  posX: number
  posY: number
  width: number
  height: number
  settings: Record<string, unknown>
}

function rowToWidget(row: DashboardWidgetRow): DashboardWidget {
  return {
    id: row.id,
    typeKey: row.type_key,
    posX: row.pos_x,
    posY: row.pos_y,
    width: row.width,
    height: row.height,
    settings: row.settings,
  }
}

export function useDashboardLayout() {
  return useQuery({
    queryKey: DASHBOARD_KEY,
    queryFn: async (): Promise<DashboardWidget[]> => {
      const { data, error } = await supabase
        .from('dashboard_widgets')
        .select('*')
        .order('pos_y', { ascending: true })
      if (error) throw error
      return data.map(rowToWidget)
    },
  })
}

export function useAddWidget() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (widget: { typeKey: string; settings: Record<string, unknown> }) => {
      const { error } = await supabase.from('dashboard_widgets').insert({
        type_key: widget.typeKey,
        pos_x: 0,
        pos_y: 9999,
        width: 4,
        height: 8,
        settings: widget.settings,
      })
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: DASHBOARD_KEY }),
  })
}

export function useRemoveWidget() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('dashboard_widgets').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: DASHBOARD_KEY }),
  })
}

export function useUpdateWidgetSettings() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, settings }: { id: string; settings: Record<string, unknown> }) => {
      const { error } = await supabase.from('dashboard_widgets').update({ settings }).eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: DASHBOARD_KEY }),
  })
}

export function useUpdateWidgetLayout() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (
      updates: Array<{ id: string; posX: number; posY: number; width: number; height: number }>
    ) => {
      const results = await Promise.all(
        updates.map(u =>
          supabase
            .from('dashboard_widgets')
            .update({ pos_x: u.posX, pos_y: u.posY, width: u.width, height: u.height })
            .eq('id', u.id)
        )
      )
      const err = results.find(r => r.error)?.error
      if (err) throw err
    },
    // No invalidation: a refetch re-renders the grid, which fires onLayoutChange
    // again and loops. Patch the cache to match what was just written.
    onSuccess: (_data, updates) => {
      qc.setQueryData<DashboardWidget[]>(DASHBOARD_KEY, prev =>
        prev?.map(w => {
          const u = updates.find(x => x.id === w.id)
          return u ? { ...w, posX: u.posX, posY: u.posY, width: u.width, height: u.height } : w
        })
      )
    },
  })
}
