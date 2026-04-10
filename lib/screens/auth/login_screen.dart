import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tavern_theme.dart';
import '../../widgets/tavern_button.dart';
import '../../widgets/tavern_snackbar.dart';
import '../../widgets/tavern_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    String? emailErr;
    String? pwErr;

    if (email.isEmpty) {
      emailErr = 'Email is required';
    } else if (!email.contains('@')) {
      emailErr = 'Enter a valid email';
    }
    if (password.isEmpty) {
      pwErr = 'Password is required';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = pwErr;
    });

    return emailErr == null && pwErr == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    try {
      if (_isSignUp) {
        await ref.read(authServiceProvider).signUpWithEmail(email, password);
        if (mounted) {
          TavernSnackbar.showSuccess(
              context, 'Account created — check your email to confirm.');
          setState(() => _isSignUp = false);
        }
      } else {
        await ref.read(authServiceProvider).signInWithEmail(email, password);
        if (mounted) context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        TavernSnackbar.showError(
            context, _isSignUp ? 'Sign-up failed — ${e.toString()}' : 'Sign-in failed — ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).continueAsGuest();
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        TavernSnackbar.showError(context, 'Could not start guest session — ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        TavernSnackbar.showError(context, 'Google sign-in failed — ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TavernColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tavernboard',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp ? 'Create your account' : 'Your campaign command center',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TavernColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TavernTextField(
                  controller: _emailController,
                  label: 'Email',
                  required: true,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() => _emailError = null),
                ),
                const SizedBox(height: 16),
                TavernTextField(
                  controller: _passwordController,
                  label: 'Password',
                  required: true,
                  errorText: _passwordError,
                  obscureText: true,
                  onChanged: (_) => setState(() => _passwordError = null),
                ),
                const SizedBox(height: 24),
                TavernButton(
                  label: _isSignUp ? 'Create Account' : 'Sign In',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() {
                    _isSignUp = !_isSignUp;
                    _emailError = null;
                    _passwordError = null;
                  }),
                  child: Text(
                    _isSignUp ? 'Already have an account? Sign In' : 'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TavernColors.accent,
                          decoration: TextDecoration.underline,
                          decorationColor: TavernColors.accent,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(child: Divider(color: TavernColors.divider)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: TextStyle(color: TavernColors.textSecondary)),
                    ),
                    Expanded(child: Divider(color: TavernColors.divider)),
                  ],
                ),
                const SizedBox(height: 12),
                TavernButton(
                  label: _isSignUp ? 'Sign up with Google' : 'Sign in with Google',
                  variant: TavernButtonVariant.secondary,
                  onPressed: _signInWithGoogle,
                  isLoading: _isLoading,
                  icon: Icons.g_mobiledata,
                ),
                const SizedBox(height: 12),
                TavernButton(
                  label: 'Continue as Guest',
                  variant: TavernButtonVariant.secondary,
                  onPressed: _continueAsGuest,
                  isLoading: _isLoading,
                  icon: Icons.person_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
