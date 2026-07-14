import { createContext, useContext, useEffect, useRef, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

interface AuthContextType {
  session: Session | null
  isLoading: boolean
  signInWithEmail: (email: string, password: string) => Promise<void>
  signUpWithEmail: (email: string, password: string) => Promise<void>
  signInAnonymously: () => Promise<void>
  signInWithGoogle: () => Promise<void>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | null>(null)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const queryClient = useQueryClient()
  const lastUserIdRef = useRef<string | null>(null)

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      lastUserIdRef.current = data.session?.user.id ?? null
      setSession(data.session)
      setIsLoading(false)
    })
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_, s) => {
      const userId = s?.user.id ?? null
      // Drop the previous user's cached data on sign-out or account switch;
      // token refreshes for the same user must not wipe the cache.
      if (userId !== lastUserIdRef.current) {
        lastUserIdRef.current = userId
        queryClient.clear()
      }
      setSession(s)
    })
    return () => subscription.unsubscribe()
  }, [queryClient])

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

  const signInWithGoogle = async () => {
    // Full-page redirect to Google; on return, detectSessionInUrl picks up the session.
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: window.location.origin },
    })
    if (error) throw error
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return (
    <AuthContext.Provider value={{ session, isLoading, signInWithEmail, signUpWithEmail, signInAnonymously, signInWithGoogle, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth(): AuthContextType {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
