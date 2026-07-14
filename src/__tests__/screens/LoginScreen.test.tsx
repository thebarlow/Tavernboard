import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import LoginScreen from '@/screens/LoginScreen'

const signInWithGoogle = vi.fn(() => Promise.resolve())

vi.mock('@/contexts/AuthContext', () => ({
  useAuth: () => ({
    session: null,
    isLoading: false,
    signInWithEmail: vi.fn(),
    signUpWithEmail: vi.fn(),
    signInAnonymously: vi.fn(),
    signInWithGoogle,
    signOut: vi.fn(),
  }),
}))

describe('LoginScreen', () => {
  it('renders the Google sign-in button', () => {
    render(<LoginScreen />)
    expect(screen.getByRole('button', { name: /sign in with google/i })).toBeInTheDocument()
  })

  it('starts the Google OAuth flow on click', async () => {
    render(<LoginScreen />)
    fireEvent.click(screen.getByRole('button', { name: /sign in with google/i }))
    await waitFor(() => expect(signInWithGoogle).toHaveBeenCalledOnce())
  })

  it('shows an error when the OAuth flow fails', async () => {
    signInWithGoogle.mockRejectedValueOnce(new Error('Provider not enabled'))
    render(<LoginScreen />)
    fireEvent.click(screen.getByRole('button', { name: /sign in with google/i }))
    expect(await screen.findByText('Provider not enabled')).toBeInTheDocument()
  })
})
