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
