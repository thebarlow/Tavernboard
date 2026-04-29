# Tavernboard React Respec — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate Tavernboard from Flutter to React, implementing a modular widget system with drag-to-resize dashboard layout backed by Supabase.

**Architecture:** Widget module pattern — each widget owns its typed config, metadata, and component in a self-contained folder. A central registry maps type keys to definitions. The dashboard reads layout from a `dashboard_widgets` Supabase table and renders widgets via react-grid-layout. Shared data (entries, projects) is fetched once via TanStack Query hooks and consumed by multiple widgets without duplicate requests.

**Tech Stack:** Vite, React 18, TypeScript 5, Tailwind CSS 3, TanStack Query v5, Supabase JS SDK v2, react-grid-layout 1.5, Vitest, React Testing Library

---

## File Map

```
(root)
  package.json
  vite.config.ts
  tsconfig.json / tsconfig.app.json / tsconfig.node.json
  index.html
  tailwind.config.js
  postcss.config.js
  _flutter_archive/        ← archived Flutter source
  supabase/
    migrations/
      001_initial_schema.sql   (existing)
      002_dashboard_widgets.sql (new)
src/
  index.css
  vite-env.d.ts
  main.tsx
  App.tsx
  lib/
    supabase.ts
    queryClient.ts
  types/
    database.ts
  contexts/
    AuthContext.tsx
  hooks/
    useEntries.ts
    useProjects.ts
    useDashboardLayout.ts
  components/
    Dialog.tsx
    WidgetSkeleton.tsx
    WidgetError.tsx
    WidgetFrame.tsx
    AddWidgetDialog.tsx
  widgets/
    widgetRegistry.ts
    index.ts                ← registers all widgets (side-effect import)
    task-list/
      config.ts
      meta.ts
      index.tsx
    calendar/
      config.ts
      meta.ts
      index.tsx
    project-board/
      config.ts
      meta.ts
      index.tsx
  screens/
    LoginScreen.tsx
    DashboardScreen.tsx
  test/
    setup.ts
  __tests__/
    widgets/
      task-list/
        config.test.ts
        TaskListWidget.test.tsx
      calendar/
        config.test.ts
      project-board/
        config.test.ts
        ProjectBoardWidget.test.tsx
```

---

## Task 1: Archive Flutter Code

**Files:**
- Create: `_flutter_archive/` (move Flutter source here)
- Modify: `.gitignore`

- [ ] **Step 1: Move Flutter source into archive directory**

```bash
mkdir _flutter_archive
mv lib test android web windows pubspec.yaml pubspec.lock \
   analysis_options.yaml tavernboard.iml .metadata \
   .flutter-plugins .flutter-plugins-dependencies \
   _flutter_archive/
```

- [ ] **Step 2: Delete build artifacts**

```bash
rm -rf build .dart_tool
```

- [ ] **Step 3: Update .gitignore**

Replace the existing `.gitignore` contents with:

```
# React / Node
node_modules/
dist/
.env
.env.local

# Vite
*.local

# Editor
.DS_Store
.idea/
*.iml
.vscode/

# Flutter archive (keep source, ignore build artifacts)
_flutter_archive/build/
_flutter_archive/.dart_tool/
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "[chore] Archive Flutter source; prepare for React migration"
```

---

## Task 2: Scaffold React + Tailwind

**Files:**
- Create: `package.json`, `vite.config.ts`, `tsconfig.json`, `tsconfig.app.json`, `tsconfig.node.json`, `index.html`, `tailwind.config.js`, `postcss.config.js`, `src/index.css`, `src/vite-env.d.ts`, `src/test/setup.ts`, `src/main.tsx`, `src/App.tsx`

- [ ] **Step 1: Create `package.json`**

```json
{
  "name": "tavernboard",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "test": "vitest"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.49.4",
    "@tanstack/react-query": "^5.74.4",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-grid-layout": "^1.5.0",
    "react-router-dom": "^7.5.3"
  },
  "devDependencies": {
    "@testing-library/jest-dom": "^6.6.3",
    "@testing-library/react": "^16.3.0",
    "@testing-library/user-event": "^14.6.1",
    "@types/react": "^18.3.20",
    "@types/react-dom": "^18.3.5",
    "@types/react-grid-layout": "^1.3.5",
    "@vitejs/plugin-react": "^4.4.1",
    "autoprefixer": "^10.4.21",
    "jsdom": "^26.1.0",
    "postcss": "^8.5.3",
    "tailwindcss": "^3.4.17",
    "typescript": "~5.8.3",
    "vite": "^6.3.2",
    "vitest": "^3.1.2"
  }
}
```

- [ ] **Step 2: Create `vite.config.ts`**

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
  },
})
```

- [ ] **Step 3: Create `tsconfig.json`**

```json
{
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ]
}
```

- [ ] **Step 4: Create `tsconfig.app.json`**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src"]
}
```

- [ ] **Step 5: Create `tsconfig.node.json`**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2023"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  },
  "include": ["vite.config.ts"]
}
```

- [ ] **Step 6: Create `index.html`**

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Tavernboard</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700&family=Lora:ital,wght@0,400;0,500;1,400&display=swap" rel="stylesheet">
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

- [ ] **Step 7: Create `tailwind.config.js`**

```js
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        oak:              { DEFAULT: '#3B1F0A', light: '#5C3D1E', dark: '#2A1507' },
        parchment:        { DEFAULT: '#C8A96E', light: '#F5E6C8', dark: '#A07840' },
        ember:            { DEFAULT: '#B5451B', light: '#C8600A', dark: '#8B3214' },
        iron:             { DEFAULT: '#4A4A4A', light: '#6B6B6B', dark: '#2D2D2D' },
        surface:          '#2C1810',
        background:       '#1A0F08',
        divider:          '#3D2B1A',
        'text-primary':   '#F5E6C8',
        'text-secondary': '#A07840',
      },
      fontFamily: {
        display: ['Cinzel', 'serif'],
        body:    ['Lora', 'serif'],
      },
    },
  },
  plugins: [],
}
```

- [ ] **Step 8: Create `postcss.config.js`**

```js
export default {
  plugins: { tailwindcss: {}, autoprefixer: {} },
}
```

- [ ] **Step 9: Create `src/index.css`**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-background text-text-primary font-body;
  }
}
```

- [ ] **Step 10: Create `src/vite-env.d.ts`**

```ts
/// <reference types="vite/client" />
```

- [ ] **Step 11: Create `src/test/setup.ts`**

```ts
import '@testing-library/jest-dom'
```

- [ ] **Step 12: Create `src/main.tsx`** (stub — will be updated in Task 5 and Task 11)

```tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```

- [ ] **Step 13: Create `src/App.tsx`** (smoke-test stub)

```tsx
export default function App() {
  return <div className="font-display text-parchment p-8 text-2xl">Tavernboard</div>
}
```

- [ ] **Step 14: Install dependencies and verify**

```bash
npm install
npm run dev
```

Expected: dev server starts on `http://localhost:5173`, browser shows "Tavernboard" in Cinzel font on a dark background.

- [ ] **Step 15: Verify TypeScript compiles**

```bash
npm run build
```

Expected: build succeeds with no errors.

- [ ] **Step 16: Commit**

```bash
git add -A
git commit -m "[chore] Scaffold Vite + React + Tailwind with tavern theme"
```

---

## Task 3: Supabase Client + Types + Env

**Files:**
- Modify: `.env`, `.env.template`
- Create: `src/lib/supabase.ts`, `src/types/database.ts`

- [ ] **Step 1: Update `.env` with Vite prefixes**

Vite only exposes env vars prefixed with `VITE_`. Open `.env` and rename the existing keys:

```
VITE_SUPABASE_URL=https://<your-project>.supabase.co
VITE_SUPABASE_ANON_KEY=<your-anon-key>
VITE_SUPABASE_REDIRECT_URL=http://localhost:5173/auth/callback
```

The actual values stay the same — only the key names change.

- [ ] **Step 2: Update `.env.template`**

```
VITE_SUPABASE_URL=https://<project-ref>.supabase.co
VITE_SUPABASE_ANON_KEY=<anon-public-key>
VITE_SUPABASE_REDIRECT_URL=http://localhost:5173/auth/callback
```

- [ ] **Step 3: Create `src/types/database.ts`**

```ts
export interface Database {
  public: {
    Tables: {
      categories: {
        Row: { id: string; user_id: string; name: string }
        Insert: Omit<Database['public']['Tables']['categories']['Row'], 'id'>
        Update: Partial<Database['public']['Tables']['categories']['Row']>
      }
      projects: {
        Row: {
          id: string; user_id: string; name: string; color: string
          category_id: string | null; deadline: string | null; created_at: string
        }
        Insert: Omit<Database['public']['Tables']['projects']['Row'], 'id' | 'created_at'>
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
        Insert: Omit<Database['public']['Tables']['entries']['Row'], 'id' | 'created_at'>
        Update: Partial<Omit<Database['public']['Tables']['entries']['Row'], 'id' | 'user_id' | 'created_at'>>
      }
      dashboard_widgets: {
        Row: {
          id: string; user_id: string; type_key: string
          pos_x: number; pos_y: number; width: number; height: number
          settings: Record<string, unknown>; created_at: string
        }
        Insert: Omit<Database['public']['Tables']['dashboard_widgets']['Row'], 'id' | 'created_at'>
        Update: Partial<Omit<Database['public']['Tables']['dashboard_widgets']['Row'], 'id' | 'user_id' | 'created_at'>>
      }
    }
  }
}

export type Entry = Database['public']['Tables']['entries']['Row']
export type Project = Database['public']['Tables']['projects']['Row']
export type DashboardWidgetRow = Database['public']['Tables']['dashboard_widgets']['Row']
```

- [ ] **Step 4: Create `src/lib/supabase.ts`**

```ts
import { createClient } from '@supabase/supabase-js'
import type { Database } from '@/types/database'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey)
```

- [ ] **Step 5: Verify TypeScript compiles**

```bash
npm run build
```

Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add src/lib/supabase.ts src/types/database.ts .env.template
git commit -m "[feat] Add Supabase client and typed database schema"
```

---

## Task 4: Migration 002 — dashboard_widgets Table

**Files:**
- Create: `supabase/migrations/002_dashboard_widgets.sql`

- [ ] **Step 1: Create the migration file**

Create `supabase/migrations/002_dashboard_widgets.sql`:

```sql
CREATE TABLE dashboard_widgets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES auth.users NOT NULL,
  type_key    TEXT NOT NULL,
  pos_x       INT NOT NULL DEFAULT 0,
  pos_y       INT NOT NULL DEFAULT 0,
  width       INT NOT NULL DEFAULT 4,
  height      INT NOT NULL DEFAULT 8,
  settings    JSONB NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE dashboard_widgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own widgets"
  ON dashboard_widgets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

- [ ] **Step 2: Apply the migration**

Open the Supabase dashboard → SQL Editor → paste the migration contents → Run.

Verify: Table Editor shows the new `dashboard_widgets` table with RLS enabled.

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/002_dashboard_widgets.sql
git commit -m "[feat] Add migration 002: dashboard_widgets table"
```

---

## Task 5: Auth Context + Login Screen + Routing

**Files:**
- Create: `src/contexts/AuthContext.tsx`, `src/screens/LoginScreen.tsx`, `src/screens/DashboardScreen.tsx` (stub)
- Modify: `src/App.tsx`, `src/lib/queryClient.ts`

- [ ] **Step 1: Create `src/lib/queryClient.ts`**

```ts
import { QueryClient } from '@tanstack/react-query'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: { staleTime: 1000 * 60, retry: 1 },
  },
})
```

- [ ] **Step 2: Create `src/contexts/AuthContext.tsx`**

```tsx
import { createContext, useContext, useEffect, useState } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

interface AuthContextType {
  session: Session | null
  isLoading: boolean
  signInWithEmail: (email: string, password: string) => Promise<void>
  signUpWithEmail: (email: string, password: string) => Promise<void>
  signInAnonymously: () => Promise<void>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | null>(null)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session)
      setIsLoading(false)
    })
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_, s) => {
      setSession(s)
    })
    return () => subscription.unsubscribe()
  }, [])

  const signInWithEmail = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  const signUpWithEmail = async (email: string, password: string) => {
    const { error } = await supabase.auth.signUp({ email, password })
    if (error) throw error
  }

  const signInAnonymously = async () => {
    const { error } = await supabase.auth.signInAnonymously()
    if (error) throw error
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return (
    <AuthContext.Provider value={{ session, isLoading, signInWithEmail, signUpWithEmail, signInAnonymously, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth(): AuthContextType {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
```

- [ ] **Step 3: Create `src/screens/LoginScreen.tsx`**

```tsx
import { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'

type Mode = 'signin' | 'signup'

export default function LoginScreen() {
  const { signInWithEmail, signUpWithEmail, signInAnonymously } = useAuth()
  const [mode, setMode] = useState<Mode>('signin')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    setIsLoading(true)
    try {
      if (mode === 'signin') await signInWithEmail(email, password)
      else await signUpWithEmail(email, password)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Authentication failed')
    } finally {
      setIsLoading(false)
    }
  }

  const handleGuest = async () => {
    setError(null)
    setIsLoading(true)
    try {
      await signInAnonymously()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to continue as guest')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <div className="w-full max-w-sm bg-surface rounded-lg border border-divider p-8">
        <h1 className="font-display text-2xl text-parchment text-center mb-8">Tavernboard</h1>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-text-secondary mb-1">Email</label>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              required
              className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary focus:outline-none focus:border-parchment"
            />
          </div>
          <div>
            <label className="block text-sm text-text-secondary mb-1">Password</label>
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              required
              className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary focus:outline-none focus:border-parchment"
            />
          </div>

          {error && <p className="text-ember text-sm">{error}</p>}

          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-ember hover:bg-ember-light disabled:opacity-50 text-parchment-light font-display py-2 rounded transition-colors"
          >
            {isLoading ? '...' : mode === 'signin' ? 'Sign In' : 'Create Account'}
          </button>
        </form>

        <button
          onClick={() => setMode(mode === 'signin' ? 'signup' : 'signin')}
          className="w-full text-center text-text-secondary text-sm mt-4 hover:text-parchment transition-colors"
        >
          {mode === 'signin' ? 'Need an account? Create one' : 'Already have an account? Sign in'}
        </button>

        <div className="flex items-center gap-3 my-4">
          <div className="flex-1 h-px bg-divider" />
          <span className="text-text-secondary text-xs">or</span>
          <div className="flex-1 h-px bg-divider" />
        </div>

        <button
          onClick={handleGuest}
          disabled={isLoading}
          className="w-full border border-divider text-text-secondary hover:text-parchment hover:border-parchment disabled:opacity-50 py-2 rounded transition-colors text-sm"
        >
          Continue as Guest
        </button>
      </div>
    </div>
  )
}
```

- [ ] **Step 4: Create `src/screens/DashboardScreen.tsx`** (stub — replaced in Task 11)

```tsx
import { useAuth } from '@/contexts/AuthContext'

export default function DashboardScreen() {
  const { signOut } = useAuth()
  return (
    <div className="min-h-screen bg-background p-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="font-display text-2xl text-parchment">Tavernboard</h1>
        <button onClick={() => signOut()} className="text-text-secondary hover:text-parchment text-sm">
          Sign Out
        </button>
      </div>
      <p className="text-text-secondary">Dashboard coming soon.</p>
    </div>
  )
}
```

- [ ] **Step 5: Replace `src/App.tsx` with routing**

```tsx
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClientProvider } from '@tanstack/react-query'
import { AuthProvider, useAuth } from '@/contexts/AuthContext'
import { queryClient } from '@/lib/queryClient'
import LoginScreen from '@/screens/LoginScreen'
import DashboardScreen from '@/screens/DashboardScreen'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { session, isLoading } = useAuth()
  if (isLoading) return <div className="min-h-screen bg-background" />
  if (!session) return <Navigate to="/login" replace />
  return <>{children}</>
}

function AppRoutes() {
  const { session, isLoading } = useAuth()
  if (isLoading) return <div className="min-h-screen bg-background" />
  return (
    <Routes>
      <Route
        path="/login"
        element={session ? <Navigate to="/" replace /> : <LoginScreen />}
      />
      <Route
        path="/"
        element={<ProtectedRoute><DashboardScreen /></ProtectedRoute>}
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <BrowserRouter>
          <AppRoutes />
        </BrowserRouter>
      </AuthProvider>
    </QueryClientProvider>
  )
}
```

- [ ] **Step 6: Verify in browser**

```bash
npm run dev
```

Expected:
- `/login` shows the login form with Cinzel font on dark background
- Sign in with a real Supabase account → redirects to `/` showing "Dashboard coming soon."
- Sign out → redirects back to `/login`
- "Continue as Guest" → redirects to `/`

- [ ] **Step 7: Commit**

```bash
git add src/
git commit -m "[feat] Add auth context, login screen, and protected routing"
```

---

## Task 6: TanStack Query + Shared Data Hooks

**Files:**
- Create: `src/hooks/useEntries.ts`, `src/hooks/useProjects.ts`, `src/hooks/useDashboardLayout.ts`

- [ ] **Step 1: Create `src/hooks/useEntries.ts`**

```ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import type { Entry } from '@/types/database'

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
    mutationFn: async (entry: Entry['Insert'] & { type: Entry['Row']['type'] }) => {
      const { error } = await supabase.from('entries').insert(entry)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ENTRIES_KEY }),
  })
}

export function useUpdateEntry() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, updates }: { id: string; updates: Partial<Entry> }) => {
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
```

Note: `Entry['Insert']` won't work directly since `Entry` is defined as `Row`. Use the full type: replace `Entry['Insert']` with the inline type from `Database['public']['Tables']['entries']['Insert']`, or just use `Omit<Entry, 'id' | 'created_at'>` for the mutation parameter.

Corrected `useCreateEntry` mutationFn signature:

```ts
mutationFn: async (entry: Omit<Entry, 'id' | 'created_at'>) => {
```

- [ ] **Step 2: Create `src/hooks/useProjects.ts`**

```ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import type { Project } from '@/types/database'

export const PROJECTS_KEY = ['projects'] as const

export function useProjects() {
  return useQuery({
    queryKey: PROJECTS_KEY,
    queryFn: async (): Promise<Project[]> => {
      const { data, error } = await supabase
        .from('projects')
        .select('*')
        .order('created_at', { ascending: false })
      if (error) throw error
      return data
    },
  })
}

export function useCreateProject() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (project: { name: string; color?: string; deadline?: string | null }) => {
      const { error } = await supabase.from('projects').insert({
        name: project.name,
        color: project.color ?? '#C8860A',
        deadline: project.deadline ?? null,
      })
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: PROJECTS_KEY }),
  })
}

export function useUpdateProject() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, updates }: { id: string; updates: Partial<Project> }) => {
      const { error } = await supabase.from('projects').update(updates).eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: PROJECTS_KEY }),
  })
}

export function useDeleteProject() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('projects').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: PROJECTS_KEY }),
  })
}
```

- [ ] **Step 3: Create `src/hooks/useDashboardLayout.ts`**

```ts
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
    onSuccess: () => qc.invalidateQueries({ queryKey: DASHBOARD_KEY }),
  })
}
```

- [ ] **Step 4: Verify TypeScript compiles**

```bash
npm run build
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add src/hooks/ src/lib/queryClient.ts
git commit -m "[feat] Add TanStack Query setup and shared data hooks"
```

---

## Task 7: Widget System Foundation

**Files:**
- Create: `src/widgets/widgetRegistry.ts`, `src/components/Dialog.tsx`, `src/components/WidgetSkeleton.tsx`, `src/components/WidgetError.tsx`, `src/components/WidgetFrame.tsx`

- [ ] **Step 1: Create `src/widgets/widgetRegistry.ts`**

```ts
import type React from 'react'

// BaseWidgetConfig is intentionally empty — a hook for future shared settings.
// Size and position are layout concerns stored as columns in dashboard_widgets,
// not as widget settings.
export interface BaseWidgetConfig {}

export interface WidgetMeta<C extends BaseWidgetConfig = BaseWidgetConfig> {
  typeKey: string
  displayName: string
  icon: string
  defaultConfig: C
  configFromJson: (json: Record<string, unknown>) => C
}

export interface WidgetDefinition<C extends BaseWidgetConfig = BaseWidgetConfig> {
  meta: WidgetMeta<C>
  Component: React.FC<{ config: C }>
}

export const widgetRegistry: Record<string, WidgetDefinition> = {}

export function registerWidget<C extends BaseWidgetConfig>(
  definition: WidgetDefinition<C>
): void {
  widgetRegistry[definition.meta.typeKey] = definition as WidgetDefinition
}
```

- [ ] **Step 2: Create `src/components/Dialog.tsx`**

```tsx
interface DialogProps {
  title: string
  children: React.ReactNode
  onClose: () => void
  onSave: () => void
  isSaving: boolean
}

export default function Dialog({ title, children, onClose, onSave, isSaving }: DialogProps) {
  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-surface border border-divider rounded-lg w-full max-w-sm p-6">
        <h3 className="font-display text-parchment mb-4">{title}</h3>
        <div className="space-y-3">{children}</div>
        <div className="flex gap-3 mt-4">
          <button
            onClick={onClose}
            className="flex-1 border border-divider text-text-secondary py-2 rounded text-sm hover:border-parchment transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={onSave}
            disabled={isSaving}
            className="flex-1 bg-ember text-parchment-light py-2 rounded text-sm disabled:opacity-50 hover:bg-ember-light transition-colors"
          >
            {isSaving ? '...' : 'Save'}
          </button>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 3: Create `src/components/WidgetSkeleton.tsx`**

```tsx
export default function WidgetSkeleton() {
  return <div className="h-full bg-surface animate-pulse rounded-lg" />
}
```

- [ ] **Step 4: Create `src/components/WidgetError.tsx`**

```tsx
interface Props { message: string }

export default function WidgetError({ message }: Props) {
  return (
    <div className="h-full flex items-center justify-center">
      <p className="text-ember text-sm">{message}</p>
    </div>
  )
}
```

- [ ] **Step 5: Create `src/components/WidgetFrame.tsx`**

The frame wraps every widget with a header (title + drag handle + remove button) and a scrollable content area.

```tsx
interface WidgetFrameProps {
  title: string
  onRemove: () => void
  children: React.ReactNode
}

export default function WidgetFrame({ title, onRemove, children }: WidgetFrameProps) {
  return (
    <div className="h-full flex flex-col bg-surface rounded-lg border border-divider overflow-hidden">
      <div className="widget-drag-handle flex items-center justify-between px-4 py-3 border-b border-divider shrink-0 cursor-grab active:cursor-grabbing">
        <h2 className="font-display text-sm text-parchment select-none">{title}</h2>
        <button
          onPointerDown={e => e.stopPropagation()}
          onClick={onRemove}
          className="text-text-secondary hover:text-ember text-lg leading-none transition-colors"
          aria-label="Remove widget"
        >
          ×
        </button>
      </div>
      <div className="flex-1 overflow-auto min-h-0">
        {children}
      </div>
    </div>
  )
}
```

Note: `onPointerDown={e => e.stopPropagation()}` on the remove button prevents react-grid-layout from treating a click on × as the start of a drag.

- [ ] **Step 6: Verify TypeScript compiles**

```bash
npm run build
```

- [ ] **Step 7: Commit**

```bash
git add src/widgets/widgetRegistry.ts src/components/
git commit -m "[feat] Add widget registry types and shared UI components"
```

---

## Task 8: Task List Widget

**Files:**
- Create: `src/__tests__/widgets/task-list/config.test.ts`, `src/__tests__/widgets/task-list/TaskListWidget.test.tsx`
- Create: `src/widgets/task-list/config.ts`, `src/widgets/task-list/meta.ts`, `src/widgets/task-list/index.tsx`

- [ ] **Step 1: Write failing config tests**

Create `src/__tests__/widgets/task-list/config.test.ts`:

```ts
import { describe, it, expect } from 'vitest'
import { taskListConfigFromJson, defaultTaskListConfig } from '@/widgets/task-list/config'

describe('taskListConfigFromJson', () => {
  it('returns defaults for empty input', () => {
    expect(taskListConfigFromJson({})).toEqual(defaultTaskListConfig)
  })

  it('overrides showCompleted', () => {
    expect(taskListConfigFromJson({ showCompleted: false }).showCompleted).toBe(false)
  })

  it('overrides projectId', () => {
    expect(taskListConfigFromJson({ projectId: 'abc' }).projectId).toBe('abc')
  })

  it('ignores non-boolean showCompleted', () => {
    expect(taskListConfigFromJson({ showCompleted: 'yes' }).showCompleted).toBe(true)
  })

  it('ignores non-string projectId', () => {
    expect(taskListConfigFromJson({ projectId: 123 }).projectId).toBeNull()
  })
})
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
npm test -- task-list/config
```

Expected: 5 failing tests — `Cannot find module '@/widgets/task-list/config'`.

- [ ] **Step 3: Create `src/widgets/task-list/config.ts`**

```ts
import type { BaseWidgetConfig } from '@/widgets/widgetRegistry'

export interface TaskListConfig extends BaseWidgetConfig {
  showCompleted: boolean
  projectId: string | null
}

export const defaultTaskListConfig: TaskListConfig = {
  showCompleted: true,
  projectId: null,
}

export function taskListConfigFromJson(json: Record<string, unknown>): TaskListConfig {
  return {
    showCompleted:
      typeof json.showCompleted === 'boolean'
        ? json.showCompleted
        : defaultTaskListConfig.showCompleted,
    projectId:
      typeof json.projectId === 'string'
        ? json.projectId
        : defaultTaskListConfig.projectId,
  }
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
npm test -- task-list/config
```

Expected: 5 passing.

- [ ] **Step 5: Write failing component test**

Create `src/__tests__/widgets/task-list/TaskListWidget.test.tsx`:

```tsx
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
  useEntries: () => ({ data: [], isLoading: false, isError: false }),
  useCreateEntry: () => ({ mutateAsync: vi.fn(), isPending: false }),
  useUpdateEntry: () => ({ mutate: vi.fn(), isPending: false }),
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
      { data: undefined, isLoading: true, isError: false } as ReturnType<typeof useEntries>
    )
    const { container } = render(<TaskListWidget config={defaultTaskListConfig} />)
    expect(container.querySelector('.animate-pulse')).toBeInTheDocument()
  })

  it('shows error message when isError is true', async () => {
    const { useEntries } = await import('@/hooks/useEntries')
    vi.mocked(useEntries).mockReturnValueOnce(
      { data: undefined, isLoading: false, isError: true } as ReturnType<typeof useEntries>
    )
    render(<TaskListWidget config={defaultTaskListConfig} />)
    expect(screen.getByText('Could not load tasks')).toBeInTheDocument()
  })

  it('renders task titles', async () => {
    const { useEntries } = await import('@/hooks/useEntries')
    vi.mocked(useEntries).mockReturnValueOnce(
      { data: [mockTask], isLoading: false, isError: false } as ReturnType<typeof useEntries>
    )
    render(<TaskListWidget config={defaultTaskListConfig} />)
    expect(screen.getByText('Buy milk')).toBeInTheDocument()
  })

  it('hides completed tasks when showCompleted is false', async () => {
    const { useEntries } = await import('@/hooks/useEntries')
    vi.mocked(useEntries).mockReturnValueOnce(
      { data: [{ ...mockTask, is_completed: true }], isLoading: false, isError: false } as ReturnType<typeof useEntries>
    )
    render(<TaskListWidget config={{ ...defaultTaskListConfig, showCompleted: false }} />)
    expect(screen.queryByText('Buy milk')).not.toBeInTheDocument()
  })
})
```

- [ ] **Step 6: Run tests to confirm they fail**

```bash
npm test -- TaskListWidget
```

Expected: failing — `Cannot find module '@/widgets/task-list'`.

- [ ] **Step 7: Create `src/widgets/task-list/index.tsx`**

```tsx
import { useState } from 'react'
import {
  useEntries,
  useCreateEntry,
  useUpdateEntry,
  useDeleteEntry,
} from '@/hooks/useEntries'
import { useProjects } from '@/hooks/useProjects'
import Dialog from '@/components/Dialog'
import WidgetSkeleton from '@/components/WidgetSkeleton'
import WidgetError from '@/components/WidgetError'
import type { Entry } from '@/types/database'
import type { TaskListConfig } from './config'

interface Props { config: TaskListConfig }

export default function TaskListWidget({ config }: Props) {
  const { data: entries, isLoading, isError } = useEntries()
  const updateEntry = useUpdateEntry()
  const deleteEntry = useDeleteEntry()
  const [showCreate, setShowCreate] = useState(false)
  const [editEntry, setEditEntry] = useState<Entry | null>(null)

  if (isLoading) return <WidgetSkeleton />
  if (isError) return <WidgetError message="Could not load tasks" />

  const tasks = (entries ?? []).filter(e => {
    if (e.type !== 'task') return false
    if (!config.showCompleted && e.is_completed) return false
    if (config.projectId && e.project_id !== config.projectId) return false
    return true
  })

  return (
    <div className="flex flex-col h-full">
      {tasks.length === 0 ? (
        <p className="flex-1 flex items-center justify-center text-text-secondary text-sm">
          No tasks
        </p>
      ) : (
        <ul className="flex-1 overflow-auto divide-y divide-divider">
          {tasks.map(task => (
            <li key={task.id} className="flex items-center gap-3 px-4 py-2">
              <input
                type="checkbox"
                checked={task.is_completed}
                onChange={() =>
                  updateEntry.mutate({
                    id: task.id,
                    updates: { is_completed: !task.is_completed },
                  })
                }
                className="accent-ember w-4 h-4 shrink-0"
              />
              <span
                className={`flex-1 text-sm ${
                  task.is_completed
                    ? 'line-through text-text-secondary'
                    : 'text-text-primary'
                }`}
              >
                {task.title}
              </span>
              <div className="flex gap-1 shrink-0">
                <button
                  onClick={() => setEditEntry(task)}
                  onPointerDown={e => e.stopPropagation()}
                  className="text-text-secondary hover:text-parchment text-xs px-1"
                  aria-label="Edit task"
                >
                  ✎
                </button>
                <button
                  onClick={() => deleteEntry.mutate(task.id)}
                  onPointerDown={e => e.stopPropagation()}
                  className="text-text-secondary hover:text-ember text-xs px-1"
                  aria-label="Delete task"
                >
                  ×
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}

      <div className="border-t border-divider p-2 shrink-0">
        <button
          onClick={() => setShowCreate(true)}
          onPointerDown={e => e.stopPropagation()}
          className="w-full text-center text-parchment text-sm py-1 hover:text-parchment-light transition-colors"
        >
          + New Task
        </button>
      </div>

      {showCreate && <CreateTaskDialog onClose={() => setShowCreate(false)} />}
      {editEntry && (
        <EditTaskDialog entry={editEntry} onClose={() => setEditEntry(null)} />
      )}
    </div>
  )
}

function CreateTaskDialog({ onClose }: { onClose: () => void }) {
  const { data: projects } = useProjects()
  const createEntry = useCreateEntry()
  const [title, setTitle] = useState('')
  const [projectId, setProjectId] = useState('')
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    if (!title.trim()) { setError('Title is required'); return }
    await createEntry.mutateAsync({
      type: 'task',
      title: title.trim(),
      project_id: projectId || null,
      is_completed: false,
      user_id: '',           // set server-side via RLS
      description: null,
      date: null,
      start_time: null,
      end_time: null,
      color_override: null,
      reminder_time: null,
      recurrence_rule: null,
    })
    onClose()
  }

  return (
    <Dialog title="New Task" onClose={onClose} onSave={handleSave} isSaving={createEntry.isPending}>
      <div>
        <input
          value={title}
          onChange={e => { setTitle(e.target.value); setError(null) }}
          placeholder="Task title"
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        />
        {error && <p className="text-ember text-xs mt-1">{error}</p>}
      </div>
      <select
        value={projectId}
        onChange={e => setProjectId(e.target.value)}
        className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
      >
        <option value="">No campaign</option>
        {(projects ?? []).map(p => (
          <option key={p.id} value={p.id}>{p.name}</option>
        ))}
      </select>
    </Dialog>
  )
}

function EditTaskDialog({ entry, onClose }: { entry: Entry; onClose: () => void }) {
  const { data: projects } = useProjects()
  const updateEntry = useUpdateEntry()
  const [title, setTitle] = useState(entry.title)
  const [projectId, setProjectId] = useState(entry.project_id ?? '')
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    if (!title.trim()) { setError('Title is required'); return }
    await updateEntry.mutateAsync({
      id: entry.id,
      updates: { title: title.trim(), project_id: projectId || null },
    })
    onClose()
  }

  return (
    <Dialog title="Edit Task" onClose={onClose} onSave={handleSave} isSaving={updateEntry.isPending}>
      <div>
        <input
          value={title}
          onChange={e => { setTitle(e.target.value); setError(null) }}
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        />
        {error && <p className="text-ember text-xs mt-1">{error}</p>}
      </div>
      <select
        value={projectId}
        onChange={e => setProjectId(e.target.value)}
        className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
      >
        <option value="">No campaign</option>
        {(projects ?? []).map(p => (
          <option key={p.id} value={p.id}>{p.name}</option>
        ))}
      </select>
    </Dialog>
  )
}
```

Note: `user_id: ''` is a placeholder — Supabase RLS sets the actual user_id server-side. The column is `NOT NULL` but Supabase uses the authenticated user's ID from the JWT automatically when inserting. Remove `user_id` from the insert payload entirely and let the server handle it, or set it from `supabase.auth.getUser()`.

Revised — remove `user_id` from the insert body in `handleSave`:

```ts
await createEntry.mutateAsync({
  type: 'task',
  title: title.trim(),
  project_id: projectId || null,
  is_completed: false,
  description: null, date: null, start_time: null, end_time: null,
  color_override: null, reminder_time: null, recurrence_rule: null,
} as Omit<Entry, 'id' | 'user_id' | 'created_at'>)
```

Update the `useCreateEntry` mutationFn type to `Omit<Entry, 'id' | 'user_id' | 'created_at'>`.

- [ ] **Step 8: Create `src/widgets/task-list/meta.ts`**

```ts
import type { WidgetMeta } from '@/widgets/widgetRegistry'
import { defaultTaskListConfig, taskListConfigFromJson, type TaskListConfig } from './config'

export const taskListMeta: WidgetMeta<TaskListConfig> = {
  typeKey: 'task_list',
  displayName: 'Task List',
  icon: '☑',
  defaultConfig: defaultTaskListConfig,
  configFromJson: taskListConfigFromJson,
}
```

- [ ] **Step 9: Run all task-list tests**

```bash
npm test -- task-list
```

Expected: all passing.

- [ ] **Step 10: Commit**

```bash
git add src/widgets/task-list/ src/__tests__/widgets/task-list/
git commit -m "[feat] Add Task List widget with typed config and tests"
```

---

## Task 9: Calendar Widget

**Files:**
- Create: `src/__tests__/widgets/calendar/config.test.ts`
- Create: `src/widgets/calendar/config.ts`, `src/widgets/calendar/meta.ts`, `src/widgets/calendar/index.tsx`

- [ ] **Step 1: Write failing config tests**

Create `src/__tests__/widgets/calendar/config.test.ts`:

```ts
import { describe, it, expect } from 'vitest'
import { calendarConfigFromJson, defaultCalendarConfig } from '@/widgets/calendar/config'

describe('calendarConfigFromJson', () => {
  it('returns defaults for empty input', () => {
    expect(calendarConfigFromJson({})).toEqual(defaultCalendarConfig)
  })

  it('overrides showWeekends', () => {
    expect(calendarConfigFromJson({ showWeekends: false }).showWeekends).toBe(false)
  })

  it('ignores non-boolean showWeekends', () => {
    expect(calendarConfigFromJson({ showWeekends: 'true' }).showWeekends).toBe(true)
  })
})
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
npm test -- calendar/config
```

Expected: failing — module not found.

- [ ] **Step 3: Create `src/widgets/calendar/config.ts`**

```ts
import type { BaseWidgetConfig } from '@/widgets/widgetRegistry'

export interface CalendarConfig extends BaseWidgetConfig {
  showWeekends: boolean
}

export const defaultCalendarConfig: CalendarConfig = {
  showWeekends: true,
}

export function calendarConfigFromJson(json: Record<string, unknown>): CalendarConfig {
  return {
    showWeekends:
      typeof json.showWeekends === 'boolean'
        ? json.showWeekends
        : defaultCalendarConfig.showWeekends,
  }
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
npm test -- calendar/config
```

Expected: 3 passing.

- [ ] **Step 5: Create `src/widgets/calendar/index.tsx`**

```tsx
import { useState } from 'react'
import { useEntries } from '@/hooks/useEntries'
import WidgetSkeleton from '@/components/WidgetSkeleton'
import WidgetError from '@/components/WidgetError'
import type { CalendarConfig } from './config'

const ALL_DAY_NAMES = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
const WEEKDAY_INDICES = [1, 2, 3, 4, 5]

function toDateStr(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

interface Props { config: CalendarConfig }

export default function CalendarWidget({ config }: Props) {
  const [focused, setFocused] = useState(() => new Date())
  const [selected, setSelected] = useState<string | null>(null)
  const { data: entries, isLoading, isError } = useEntries()

  if (isLoading) return <WidgetSkeleton />
  if (isError) return <WidgetError message="Could not load calendar" />

  const year = focused.getFullYear()
  const month = focused.getMonth()
  const firstDay = new Date(year, month, 1)
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const startOffset = firstDay.getDay()
  const todayStr = toDateStr(new Date())
  const monthLabel = firstDay.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })

  // Map: date string → array of dot colors
  const dotMap = new Map<string, string[]>()
  for (const e of entries ?? []) {
    if (!e.date) continue
    const existing = dotMap.get(e.date) ?? []
    existing.push(e.color_override ?? '#C8A96E')
    dotMap.set(e.date, existing)
  }

  // Build flat grid cells: null = empty padding, Date = a real day
  type Cell = { date: Date; str: string } | null
  const cells: Cell[] = []
  for (let i = 0; i < startOffset; i++) cells.push(null)
  for (let d = 1; d <= daysInMonth; d++) {
    const date = new Date(year, month, d)
    cells.push({ date, str: toDateStr(date) })
  }
  while (cells.length % 7 !== 0) cells.push(null)

  const dayNames = config.showWeekends
    ? ALL_DAY_NAMES
    : ALL_DAY_NAMES.filter((_, i) => WEEKDAY_INDICES.includes(i))

  // Filter cells to remove weekend columns if needed
  const visibleCells = config.showWeekends
    ? cells
    : cells.filter((_, i) => WEEKDAY_INDICES.includes(i % 7))

  const cols = config.showWeekends ? 7 : 5
  // Tailwind needs static class names — use inline style for grid columns
  const gridStyle = { display: 'grid', gridTemplateColumns: `repeat(${cols}, minmax(0, 1fr))`, gap: '2px' }

  return (
    <div className="p-3 flex flex-col gap-2 h-full overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between shrink-0">
        <button
          onClick={() => setFocused(new Date(year, month - 1, 1))}
          onPointerDown={e => e.stopPropagation()}
          className="text-parchment hover:text-parchment-light text-lg px-1 leading-none"
        >
          ‹
        </button>
        <span className="font-display text-xs text-parchment">{monthLabel}</span>
        <button
          onClick={() => setFocused(new Date(year, month + 1, 1))}
          onPointerDown={e => e.stopPropagation()}
          className="text-parchment hover:text-parchment-light text-lg px-1 leading-none"
        >
          ›
        </button>
      </div>

      {/* Day name headers */}
      <div style={gridStyle} className="shrink-0">
        {dayNames.map(d => (
          <div key={d} className="text-center text-text-secondary text-xs py-1">{d}</div>
        ))}
      </div>

      {/* Day cells */}
      <div style={gridStyle} className="flex-1 overflow-hidden">
        {visibleCells.map((cell, i) => {
          if (!cell) return <div key={`empty-${i}`} />
          const isToday = cell.str === todayStr
          const isSelected = cell.str === selected
          const dots = dotMap.get(cell.str) ?? []

          return (
            <button
              key={cell.str}
              onPointerDown={e => e.stopPropagation()}
              onClick={() => setSelected(cell.str === selected ? null : cell.str)}
              className={[
                'flex flex-col items-center pt-0.5 rounded text-xs transition-colors',
                isToday ? 'bg-ember text-parchment-light' : '',
                isSelected && !isToday ? 'bg-parchment/20 text-parchment' : '',
                !isToday && !isSelected ? 'text-text-primary hover:bg-white/5' : '',
              ].join(' ')}
            >
              <span>{cell.date.getDate()}</span>
              {dots.length > 0 && (
                <div className="flex gap-px mt-px flex-wrap justify-center">
                  {dots.slice(0, 3).map((color, di) => (
                    <div
                      key={di}
                      className="w-1 h-1 rounded-full"
                      style={{ backgroundColor: color }}
                    />
                  ))}
                </div>
              )}
            </button>
          )
        })}
      </div>
    </div>
  )
}
```

- [ ] **Step 6: Create `src/widgets/calendar/meta.ts`**

```ts
import type { WidgetMeta } from '@/widgets/widgetRegistry'
import { defaultCalendarConfig, calendarConfigFromJson, type CalendarConfig } from './config'

export const calendarMeta: WidgetMeta<CalendarConfig> = {
  typeKey: 'calendar',
  displayName: 'Calendar',
  icon: '📅',
  defaultConfig: defaultCalendarConfig,
  configFromJson: calendarConfigFromJson,
}
```

- [ ] **Step 7: Run all calendar tests**

```bash
npm test -- calendar
```

Expected: all passing.

- [ ] **Step 8: Commit**

```bash
git add src/widgets/calendar/ src/__tests__/widgets/calendar/
git commit -m "[feat] Add Calendar widget with custom monthly grid"
```

---

## Task 10: Project Board Widget

**Files:**
- Create: `src/__tests__/widgets/project-board/config.test.ts`, `src/__tests__/widgets/project-board/ProjectBoardWidget.test.tsx`
- Create: `src/widgets/project-board/config.ts`, `src/widgets/project-board/meta.ts`, `src/widgets/project-board/index.tsx`

- [ ] **Step 1: Write failing config tests**

Create `src/__tests__/widgets/project-board/config.test.ts`:

```ts
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
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
npm test -- project-board/config
```

Expected: failing — module not found.

- [ ] **Step 3: Create `src/widgets/project-board/config.ts`**

```ts
import type { BaseWidgetConfig } from '@/widgets/widgetRegistry'

export interface ProjectBoardConfig extends BaseWidgetConfig {
  maxProjects: number
}

export const defaultProjectBoardConfig: ProjectBoardConfig = {
  maxProjects: 10,
}

export function projectBoardConfigFromJson(json: Record<string, unknown>): ProjectBoardConfig {
  const raw = json.maxProjects
  const maxProjects =
    typeof raw === 'number' && raw >= 1
      ? Math.max(1, Math.floor(raw))
      : defaultProjectBoardConfig.maxProjects
  return { maxProjects }
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
npm test -- project-board/config
```

Expected: 4 passing.

- [ ] **Step 5: Write failing component test**

Create `src/__tests__/widgets/project-board/ProjectBoardWidget.test.tsx`:

```tsx
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
  useProjects: () => ({ data: [], isLoading: false, isError: false }),
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
      { data: [mockProject], isLoading: false, isError: false } as ReturnType<typeof useProjects>
    )
    render(<ProjectBoardWidget config={defaultProjectBoardConfig} />)
    expect(screen.getByText('Short Film')).toBeInTheDocument()
  })

  it('respects maxProjects limit', async () => {
    const { useProjects } = await import('@/hooks/useProjects')
    const many = Array.from({ length: 5 }, (_, i) => ({ ...mockProject, id: String(i), name: `Project ${i}` }))
    vi.mocked(useProjects).mockReturnValueOnce(
      { data: many, isLoading: false, isError: false } as ReturnType<typeof useProjects>
    )
    render(<ProjectBoardWidget config={{ maxProjects: 2 }} />)
    expect(screen.getAllByRole('listitem')).toHaveLength(2)
  })
})
```

- [ ] **Step 6: Run tests to confirm they fail**

```bash
npm test -- ProjectBoardWidget
```

Expected: failing — module not found.

- [ ] **Step 7: Create `src/widgets/project-board/index.tsx`**

```tsx
import { useState } from 'react'
import {
  useProjects,
  useCreateProject,
  useUpdateProject,
  useDeleteProject,
} from '@/hooks/useProjects'
import Dialog from '@/components/Dialog'
import WidgetSkeleton from '@/components/WidgetSkeleton'
import WidgetError from '@/components/WidgetError'
import type { Project } from '@/types/database'
import type { ProjectBoardConfig } from './config'

const SWATCH_COLORS = [
  '#C8860A', '#8B4513', '#5C3D1E', '#27AE60',
  '#2980B9', '#8E44AD', '#C0392B', '#F5E6C8',
]

interface Props { config: ProjectBoardConfig }

export default function ProjectBoardWidget({ config }: Props) {
  const { data: projects, isLoading, isError } = useProjects()
  const deleteProject = useDeleteProject()
  const [showCreate, setShowCreate] = useState(false)
  const [editProject, setEditProject] = useState<Project | null>(null)

  if (isLoading) return <WidgetSkeleton />
  if (isError) return <WidgetError message="Could not load campaigns" />

  const displayed = (projects ?? []).slice(0, config.maxProjects)

  return (
    <div className="flex flex-col h-full">
      {displayed.length === 0 ? (
        <p className="flex-1 flex items-center justify-center text-text-secondary text-sm">
          No campaigns yet
        </p>
      ) : (
        <ul className="flex-1 overflow-auto divide-y divide-divider">
          {displayed.map(project => {
            const dotColor = (() => {
              try { return project.color } catch { return '#C8A96E' }
            })()
            return (
              <li key={project.id} className="flex items-center gap-3 px-4 py-2">
                <div
                  className="w-3 h-3 rounded-full shrink-0"
                  style={{ backgroundColor: dotColor }}
                />
                <div className="flex-1 min-w-0">
                  <p className="text-text-primary text-sm truncate">{project.name}</p>
                  {project.deadline && (
                    <p className="text-text-secondary text-xs">
                      Due {project.deadline.split('T')[0]}
                    </p>
                  )}
                </div>
                <div className="flex gap-1 shrink-0">
                  <button
                    onClick={() => setEditProject(project)}
                    onPointerDown={e => e.stopPropagation()}
                    className="text-text-secondary hover:text-parchment text-xs px-1"
                    aria-label="Edit campaign"
                  >
                    ✎
                  </button>
                  <button
                    onClick={() => deleteProject.mutate(project.id)}
                    onPointerDown={e => e.stopPropagation()}
                    className="text-text-secondary hover:text-ember text-xs px-1"
                    aria-label="Delete campaign"
                  >
                    ×
                  </button>
                </div>
              </li>
            )
          })}
        </ul>
      )}

      <div className="border-t border-divider p-2 shrink-0">
        <button
          onClick={() => setShowCreate(true)}
          onPointerDown={e => e.stopPropagation()}
          className="w-full text-center text-parchment text-sm py-1 hover:text-parchment-light transition-colors"
        >
          + New Campaign
        </button>
      </div>

      {showCreate && <CreateProjectDialog onClose={() => setShowCreate(false)} />}
      {editProject && (
        <EditProjectDialog project={editProject} onClose={() => setEditProject(null)} />
      )}
    </div>
  )
}

function CreateProjectDialog({ onClose }: { onClose: () => void }) {
  const createProject = useCreateProject()
  const [name, setName] = useState('')
  const [color, setColor] = useState(SWATCH_COLORS[0])
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    if (!name.trim()) { setError('Name is required'); return }
    await createProject.mutateAsync({ name: name.trim(), color })
    onClose()
  }

  return (
    <Dialog title="New Campaign" onClose={onClose} onSave={handleSave} isSaving={createProject.isPending}>
      <div>
        <input
          value={name}
          onChange={e => { setName(e.target.value); setError(null) }}
          placeholder="Campaign name"
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        />
        {error && <p className="text-ember text-xs mt-1">{error}</p>}
      </div>
      <ColorPicker selected={color} onChange={setColor} />
    </Dialog>
  )
}

function EditProjectDialog({ project, onClose }: { project: Project; onClose: () => void }) {
  const updateProject = useUpdateProject()
  const [name, setName] = useState(project.name)
  const [color, setColor] = useState(project.color)
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    if (!name.trim()) { setError('Name is required'); return }
    await updateProject.mutateAsync({ id: project.id, updates: { name: name.trim(), color } })
    onClose()
  }

  return (
    <Dialog title="Edit Campaign" onClose={onClose} onSave={handleSave} isSaving={updateProject.isPending}>
      <div>
        <input
          value={name}
          onChange={e => { setName(e.target.value); setError(null) }}
          className="w-full bg-background border border-divider rounded px-3 py-2 text-text-primary text-sm focus:outline-none focus:border-parchment"
        />
        {error && <p className="text-ember text-xs mt-1">{error}</p>}
      </div>
      <ColorPicker selected={color} onChange={setColor} />
    </Dialog>
  )
}

function ColorPicker({ selected, onChange }: { selected: string; onChange: (c: string) => void }) {
  return (
    <div>
      <p className="text-text-secondary text-xs mb-2">Color</p>
      <div className="flex gap-2 flex-wrap">
        {SWATCH_COLORS.map(c => (
          <button
            key={c}
            onPointerDown={e => e.stopPropagation()}
            onClick={() => onChange(c)}
            className={`w-6 h-6 rounded-full border-2 transition-colors ${
              selected === c ? 'border-parchment-light' : 'border-transparent'
            }`}
            style={{ backgroundColor: c }}
            aria-label={c}
          />
        ))}
      </div>
    </div>
  )
}
```

- [ ] **Step 8: Create `src/widgets/project-board/meta.ts`**

```ts
import type { WidgetMeta } from '@/widgets/widgetRegistry'
import { defaultProjectBoardConfig, projectBoardConfigFromJson, type ProjectBoardConfig } from './config'

export const projectBoardMeta: WidgetMeta<ProjectBoardConfig> = {
  typeKey: 'project_board',
  displayName: 'Campaigns',
  icon: '🏰',
  defaultConfig: defaultProjectBoardConfig,
  configFromJson: projectBoardConfigFromJson,
}
```

- [ ] **Step 9: Run all project-board tests**

```bash
npm test -- project-board
```

Expected: all passing.

- [ ] **Step 10: Commit**

```bash
git add src/widgets/project-board/ src/__tests__/widgets/project-board/
git commit -m "[feat] Add Project Board widget with create/edit/delete and color picker"
```

---

## Task 11: Dashboard Screen + Widget Registration

**Files:**
- Create: `src/widgets/index.ts`, `src/components/AddWidgetDialog.tsx`
- Modify: `src/main.tsx`, `src/screens/DashboardScreen.tsx`

- [ ] **Step 1: Create `src/widgets/index.ts`** (registers all widgets as a side-effect)

```ts
import { registerWidget } from './widgetRegistry'
import { taskListMeta } from './task-list/meta'
import TaskListWidget from './task-list'
import { calendarMeta } from './calendar/meta'
import CalendarWidget from './calendar'
import { projectBoardMeta } from './project-board/meta'
import ProjectBoardWidget from './project-board'

registerWidget({ meta: taskListMeta, Component: TaskListWidget })
registerWidget({ meta: calendarMeta, Component: CalendarWidget })
registerWidget({ meta: projectBoardMeta, Component: ProjectBoardWidget })
```

- [ ] **Step 2: Import widgets in `src/main.tsx`**

Add `import '@/widgets/index'` before the App import:

```tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import '@/widgets/index'
import App from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```

- [ ] **Step 3: Create `src/components/AddWidgetDialog.tsx`**

```tsx
import { widgetRegistry } from '@/widgets/widgetRegistry'
import { useAddWidget } from '@/hooks/useDashboardLayout'

interface Props { onClose: () => void }

export default function AddWidgetDialog({ onClose }: Props) {
  const addWidget = useAddWidget()

  const handleAdd = async (typeKey: string) => {
    const def = widgetRegistry[typeKey]
    if (!def) return
    await addWidget.mutateAsync({
      typeKey,
      settings: def.meta.defaultConfig as Record<string, unknown>,
    })
    onClose()
  }

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-surface border border-divider rounded-lg w-full max-w-sm p-6">
        <h3 className="font-display text-parchment mb-4">Add Widget</h3>
        <div className="space-y-2">
          {Object.values(widgetRegistry).map(def => (
            <button
              key={def.meta.typeKey}
              onClick={() => handleAdd(def.meta.typeKey)}
              disabled={addWidget.isPending}
              className="w-full flex items-center gap-3 p-3 border border-divider rounded hover:border-parchment text-left transition-colors disabled:opacity-50"
            >
              <span className="text-xl">{def.meta.icon}</span>
              <span className="text-text-primary text-sm">{def.meta.displayName}</span>
            </button>
          ))}
        </div>
        <button
          onClick={onClose}
          className="w-full mt-4 border border-divider text-text-secondary py-2 rounded text-sm hover:border-parchment transition-colors"
        >
          Cancel
        </button>
      </div>
    </div>
  )
}
```

- [ ] **Step 4: Replace `src/screens/DashboardScreen.tsx` with the full implementation**

Note on react-grid-layout + React 18: `WidthProvider` uses a `ResizeObserver` internally (since v1.4). Use `WidthProvider(GridLayout)` to automatically track container width.

```tsx
import { useState, useCallback, useRef } from 'react'
import GridLayout, { WidthProvider, type Layout } from 'react-grid-layout'
import 'react-grid-layout/css/styles.css'
import 'react-resizable/css/styles.css'
import { useAuth } from '@/contexts/AuthContext'
import {
  useDashboardLayout,
  useRemoveWidget,
  useUpdateWidgetLayout,
} from '@/hooks/useDashboardLayout'
import { widgetRegistry } from '@/widgets/widgetRegistry'
import WidgetFrame from '@/components/WidgetFrame'
import WidgetSkeleton from '@/components/WidgetSkeleton'
import AddWidgetDialog from '@/components/AddWidgetDialog'

const ResponsiveGrid = WidthProvider(GridLayout)
const DEBOUNCE_MS = 800

export default function DashboardScreen() {
  const { signOut } = useAuth()
  const { data: widgets, isLoading } = useDashboardLayout()
  const removeWidget = useRemoveWidget()
  const updateLayout = useUpdateWidgetLayout()
  const [showAdd, setShowAdd] = useState(false)
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const handleLayoutChange = useCallback(
    (layout: Layout[]) => {
      if (debounceRef.current) clearTimeout(debounceRef.current)
      debounceRef.current = setTimeout(() => {
        updateLayout.mutate(
          layout.map(item => ({
            id: item.i,
            posX: item.x,
            posY: item.y,
            width: item.w,
            height: item.h,
          }))
        )
      }, DEBOUNCE_MS)
    },
    [updateLayout]
  )

  const layout: Layout[] = (widgets ?? []).map(w => ({
    i: w.id,
    x: w.posX,
    y: w.posY,
    w: w.width,
    h: w.height,
  }))

  return (
    <div className="min-h-screen bg-background">
      <header className="flex items-center justify-between px-6 py-4 border-b border-divider">
        <h1 className="font-display text-xl text-parchment">Tavernboard</h1>
        <div className="flex items-center gap-3">
          <button
            onClick={() => setShowAdd(true)}
            className="bg-ember hover:bg-ember-light text-parchment-light font-display text-sm px-4 py-2 rounded transition-colors"
          >
            + Add Widget
          </button>
          <button
            onClick={() => signOut()}
            className="text-text-secondary hover:text-parchment text-sm transition-colors"
          >
            Sign Out
          </button>
        </div>
      </header>

      <main className="p-4">
        {isLoading ? (
          <div className="grid grid-cols-3 gap-4">
            {[1, 2, 3].map(i => (
              <div key={i} className="h-80">
                <WidgetSkeleton />
              </div>
            ))}
          </div>
        ) : (widgets ?? []).length === 0 ? (
          <div className="flex flex-col items-center justify-center h-96 text-text-secondary gap-4">
            <p>Your board is empty.</p>
            <button
              onClick={() => setShowAdd(true)}
              className="text-parchment hover:text-parchment-light underline"
            >
              Add a widget
            </button>
          </div>
        ) : (
          <ResponsiveGrid
            layout={layout}
            cols={12}
            rowHeight={40}
            onLayoutChange={handleLayoutChange}
            draggableHandle=".widget-drag-handle"
          >
            {(widgets ?? []).map(w => {
              const def = widgetRegistry[w.typeKey]
              if (!def) return <div key={w.id} />
              const config = def.meta.configFromJson(w.settings)
              return (
                <div key={w.id}>
                  <WidgetFrame
                    title={def.meta.displayName}
                    onRemove={() => removeWidget.mutate(w.id)}
                  >
                    <def.Component config={config} />
                  </WidgetFrame>
                </div>
              )
            })}
          </ResponsiveGrid>
        )}
      </main>

      {showAdd && <AddWidgetDialog onClose={() => setShowAdd(false)} />}
    </div>
  )
}
```

- [ ] **Step 5: Run full test suite**

```bash
npm test
```

Expected: all tests passing. Fix any TypeScript errors before continuing.

- [ ] **Step 6: Build to verify no type errors**

```bash
npm run build
```

Expected: clean build.

- [ ] **Step 7: Manual smoke test in browser**

```bash
npm run dev
```

Verify:
1. Sign in → dashboard shows empty state with "Add a widget" link
2. Click "+ Add Widget" → dialog shows Task List, Calendar, Campaigns
3. Add Task List → widget appears on dashboard
4. Add Calendar → second widget appears
5. Drag widgets by their headers → layout changes
6. Resize a widget by dragging its corner → size changes
7. Reload page → layout persists (loaded from Supabase)
8. Click × on a widget → widget is removed and persisted
9. Create a task via the Task List widget → appears in the list
10. Toggle task completion → checkbox updates immediately

- [ ] **Step 8: Commit**

```bash
git add src/
git commit -m "[feat] Complete dashboard with react-grid-layout and widget registration"
```

---

## Self-Review Checklist

- [x] **Spec coverage**
  - Stack (Vite, React 18, TS, Tailwind, TanStack Query, Supabase, react-grid-layout) → Tasks 2–3
  - Widget module pattern (config, meta, component per widget) → Tasks 7–10
  - Central registry + `widgets/index.ts` side-effect import → Task 11
  - Shared TanStack Query hooks, deduplication → Task 6
  - `dashboard_widgets` structured table (migration 002) → Task 4
  - Layout persistence via debounced `onLayoutChange` → Task 11
  - Add/remove widgets via dialog → Task 11
  - Auth (email/password, anonymous guest, protected routes) → Task 5
  - Tailwind tavern theme tokens → Task 2
  - Unit tests (config fromJson) + component tests (loading/error/data states) → Tasks 8–10
  - `BaseWidgetConfig` intentionally empty; size/position are DB columns not settings → Task 7

- [x] **No placeholders** — all code blocks are complete

- [x] **Type consistency**
  - `DashboardWidget` (camelCase app type) defined in `useDashboardLayout.ts`, used in `DashboardScreen.tsx`
  - `widgetRegistry` typed as `Record<string, WidgetDefinition>` throughout
  - `taskListConfigFromJson` / `calendarConfigFromJson` / `projectBoardConfigFromJson` all return their named config type
  - `WidgetFrame` uses `.widget-drag-handle` CSS class — matched by `draggableHandle=".widget-drag-handle"` in `ResponsiveGrid`
  - `onPointerDown={e => e.stopPropagation()}` on all interactive elements inside widgets prevents drag conflicts
