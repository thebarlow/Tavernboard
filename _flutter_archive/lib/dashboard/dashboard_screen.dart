import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/tavern_theme.dart';
import '../widgets/tavern_snackbar.dart';
import 'dashboard_grid.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _sidebarOpen = true;

  Future<void> _signOut() async {
    try {
      await ref.read(authServiceProvider).signOut();
      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) TavernSnackbar.showError(context, 'Sign-out failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tavernboard'),
        leading: IconButton(
          icon: Icon(_sidebarOpen && !isNarrow ? Icons.menu_open : Icons.menu),
          onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: _signOut,
          ),
        ],
      ),
      drawer: isNarrow ? _buildDrawer(context) : null,
      body: isNarrow
          ? const DashboardGrid()
          : Row(
              children: [
                if (_sidebarOpen) _buildSidebar(context),
                const Expanded(child: DashboardGrid()),
              ],
            ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200,
      color: TavernColors.surface,
      child: _buildNavItems(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: TavernColors.surface,
      child: _buildNavItems(context),
    );
  }

  Widget _buildNavItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        _NavItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          onTap: () {
            if (MediaQuery.of(context).size.width < 600) Navigator.of(context).pop();
          },
        ),
        _NavItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            if (MediaQuery.of(context).size.width < 600) Navigator.of(context).pop();
            TavernSnackbar.show(context, 'Settings coming soon');
          },
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: TavernColors.accent, size: 20),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
