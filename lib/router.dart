import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard/dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_callback_screen.dart';
import 'screens/auth/login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation.startsWith('/auth/') ||
          state.matchedLocation.startsWith('/share/');

      return authStateAsync.when(
        data: (authState) {
          final isSignedOut = authState.event == AuthChangeEvent.signedOut ||
              (authState.event == AuthChangeEvent.initialSession &&
                  authState.session == null);
          if (isSignedOut && !isAuthRoute) return '/login';
          if (!isSignedOut && state.matchedLocation == '/login') return '/dashboard';
          return null;
        },
        loading: () => null,
        error: (_, __) => '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (_, __) => const AuthCallbackScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
    ],
  );
});
