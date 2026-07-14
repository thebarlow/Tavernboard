type CategoryRow = {
  id: string
  user_id: string
  name: string
}

type ProjectRow = {
  id: string
  user_id: string
  name: string
  color: string
  category_id: string | null
  deadline: string | null
  created_at: string
}

type EntryRow = {
  id: string
  user_id: string
  project_id: string | null
  type: 'task' | 'event' | 'deadline' | 'habit' | 'habit_checkin'
  title: string
  description: string | null
  date: string | null
  start_time: string | null
  end_time: string | null
  color_override: string | null
  is_completed: boolean
  reminder_time: string | null
  recurrence_rule: string | null
  created_at: string
}

type DashboardWidgetsRow = {
  id: string
  user_id: string
  type_key: string
  pos_x: number
  pos_y: number
  width: number
  height: number
  settings: Record<string, unknown>
  created_at: string
}

// Insert types omit id/created_at (DB-generated) and make user_id optional
// (column defaults to auth.uid(), migration 002).
export type Database = {
  public: {
    Tables: {
      categories: {
        Row: CategoryRow
        Insert: Omit<CategoryRow, 'id' | 'user_id'> & { user_id?: string }
        Update: Partial<Omit<CategoryRow, 'id' | 'user_id'>>
        Relationships: []
      }
      projects: {
        Row: ProjectRow
        Insert: Omit<ProjectRow, 'id' | 'user_id' | 'created_at'> & { user_id?: string }
        Update: Partial<Omit<ProjectRow, 'id' | 'user_id' | 'created_at'>>
        Relationships: []
      }
      entries: {
        Row: EntryRow
        Insert: Omit<EntryRow, 'id' | 'user_id' | 'created_at'> & { user_id?: string }
        Update: Partial<Omit<EntryRow, 'id' | 'user_id' | 'created_at'>>
        Relationships: []
      }
      dashboard_widgets: {
        Row: DashboardWidgetsRow
        Insert: Omit<DashboardWidgetsRow, 'id' | 'user_id' | 'created_at'> & { user_id?: string }
        Update: Partial<Omit<DashboardWidgetsRow, 'id' | 'user_id' | 'created_at'>>
        Relationships: []
      }
    }
    Views: Record<string, never>
    Functions: Record<string, never>
    Enums: Record<string, never>
    CompositeTypes: Record<string, never>
  }
}

export type Entry = EntryRow
export type EntryInsert = Database['public']['Tables']['entries']['Insert']
export type Project = ProjectRow
export type DashboardWidgetRow = DashboardWidgetsRow
export type EntryUpdate = Database['public']['Tables']['entries']['Update']
export type ProjectUpdate = Database['public']['Tables']['projects']['Update']
