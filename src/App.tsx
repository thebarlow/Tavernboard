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
