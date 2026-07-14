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
