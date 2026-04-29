import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_client.dart';
import '../../theme/tavern_theme.dart';
import '../../widgets/tavern_snackbar.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    try {
      await supabase.auth.getSessionFromUrl(Uri.base);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        TavernSnackbar.showError(context, 'Sign-in failed — please try again');
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TavernColors.background,
      body: Center(
        child: CircularProgressIndicator(color: TavernColors.accent),
      ),
    );
  }
}
