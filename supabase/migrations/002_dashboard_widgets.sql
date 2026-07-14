CREATE TABLE dashboard_widgets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  type_key    TEXT NOT NULL,
  pos_x       INT NOT NULL DEFAULT 0,
  pos_y       INT NOT NULL DEFAULT 0,
  width       INT NOT NULL DEFAULT 4,
  height      INT NOT NULL DEFAULT 8,
  settings    JSONB NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_dashboard_widgets_user_id ON dashboard_widgets(user_id);

ALTER TABLE dashboard_widgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own widgets"
  ON dashboard_widgets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS does NOT populate user_id on insert; these defaults let clients omit it.
ALTER TABLE entries    ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE projects   ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE categories ALTER COLUMN user_id SET DEFAULT auth.uid();
