import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import type { Entry, EntryInsert, EntryUpdate } from '@/types/database'

export const ENTRIES_KEY = ['entries'] as const

export function useEntries() {
  return useQuery({
    queryKey: ENTRIES_KEY,
    queryFn: async (): Promise<Entry[]> => {
      const { data, error } = await supabase
        .from('entries')
        .select('*')
        .order('created_at', { ascending: false })
      if (error) throw error
      return data
    },
  })
}

export function useCreateEntry() {
  const qc = useQueryClient()
  return useMutation({
    // user_id is omitted: the column defaults to auth.uid() (migration 002)
    mutationFn: async (entry: EntryInsert) => {
      const { error } = await supabase.from('entries').insert(entry)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ENTRIES_KEY }),
  })
}

export function useUpdateEntry() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, updates }: { id: string; updates: EntryUpdate }) => {
      const { error } = await supabase.from('entries').update(updates).eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ENTRIES_KEY }),
  })
}

export function useDeleteEntry() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('entries').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ENTRIES_KEY }),
  })
}
