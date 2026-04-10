-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL
);
CREATE INDEX idx_categories_user_id ON categories(user_id);
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories_owner" ON categories
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Projects
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#C8860A',
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  deadline TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_category_id ON projects(category_id);
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "projects_owner" ON projects
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Entries
CREATE TABLE entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  type TEXT NOT NULL CHECK (type IN ('task','event','deadline','habit','habit_checkin')),
  title TEXT NOT NULL,
  description TEXT,
  date DATE,
  start_time TIME,
  end_time TIME,
  color_override TEXT,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  reminder_time TIMESTAMPTZ,
  recurrence_rule TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_entries_user_id ON entries(user_id);
CREATE INDEX idx_entries_project_id ON entries(project_id);
CREATE INDEX idx_entries_date ON entries(date);
CREATE INDEX idx_entries_type ON entries(type);
ALTER TABLE entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "entries_owner" ON entries
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Recurrence exceptions
CREATE TABLE recurrence_exceptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
  original_date DATE NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('skip','reschedule')),
  new_date DATE
);
CREATE INDEX idx_recurrence_exceptions_entry_id ON recurrence_exceptions(entry_id);
ALTER TABLE recurrence_exceptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "recurrence_exceptions_owner" ON recurrence_exceptions
  USING (
    EXISTS (SELECT 1 FROM entries WHERE entries.id = entry_id AND entries.user_id = auth.uid())
  );
