export interface Database {
  public: {
    Tables: {
      categories: {
        Row: { id: string; user_id: string; name: string }
        Insert: Omit<Database['public']['Tables']['categories']['Row'], 'id' | 'user_id'> &
          Partial<Pick<Database['public']['Tables']['categories']['Row'], 'user_id'>>
        Update: Partial<Database['public']['Tables']['categories']['Row']>
      }
      projects: {
        Row: {
          id: string; user_id: string; name: string; color: string
          category_id: string | null; deadline: string | null; created_at: string
        }
        Insert: Omit<Database['public']['Tables']['projects']['Row'], 'id' | 'user_id' | 'created_at'> &
          Partial<Pick<Database['public']['Tables']['projects']['Row'], 'user_id'>>
        Update: Partial<Omit<Database['public']['Tables']['projects']['Row'], 'id' | 'user_id' | 'created_at'>>
      }
      entries: {
        Row: {
          id: string; user_id: string; project_id: string | null
          type: 'task' | 'event' | 'deadline' | 'habit' | 'habit_checkin'
          title: string; description: string | null; date: string | null
          start_time: string | null; end_time: string | null
          color_override: string | null; is_completed: boolean
          reminder_time: string | null; recurrence_rule: string | null; created_at: string
        }
        Insert: Omit<Database['public']['Tables']['entries']['Row'], 'id' | 'user_id' | 'created_at'> &
          Partial<Pick<Database['public']['Tables']['entries']['Row'], 'user_id'>>
        Update: Partial<Omit<Database['public']['Tables']['entries']['Row'], 'id' | 'user_id' | 'created_at'>>
      }
      dashboard_widgets: {
        Row: {
          id: string; user_id: string; type_key: string
          pos_x: number; pos_y: number; width: number; height: number
          settings: Record<string, unknown>; created_at: string
        }
        Insert: Omit<Database['public']['Tables']['dashboard_widgets']['Row'], 'id' | 'user_id' | 'created_at'> &
          Partial<Pick<Database['public']['Tables']['dashboard_widgets']['Row'], 'user_id'>>
        Update: Partial<Omit<Database['public']['Tables']['dashboard_widgets']['Row'], 'id' | 'user_id' | 'created_at'>>
      }
    }
  }
}

export type Entry = Database['public']['Tables']['entries']['Row']
export type EntryInsert = Database['public']['Tables']['entries']['Insert']
export type Project = Database['public']['Tables']['projects']['Row']
export type DashboardWidgetRow = Database['public']['Tables']['dashboard_widgets']['Row']
