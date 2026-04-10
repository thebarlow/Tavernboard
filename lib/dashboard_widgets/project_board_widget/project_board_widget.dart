import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/widget_registry.dart';
import '../../models/project.dart';
import '../../models/widget_config.dart';
import '../../providers/project_provider.dart';
import '../../theme/tavern_theme.dart';
import '../../widgets/tavern_dialog.dart';
import '../../widgets/tavern_snackbar.dart';
import '../../widgets/tavern_text_field.dart';
import '../base_widget.dart';
import 'project_board_widget_config.dart';

class ProjectBoardWidget extends BaseWidget {
  const ProjectBoardWidget({super.key, required super.config});

  static void register() {
    WidgetRegistry.register(
      'project_board',
      (config) => ProjectBoardWidget(config: config),
    );
  }

  @override
  String get widgetTitle => 'Campaigns';

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    return _ProjectBoardContent(config: config);
  }
}

class _ProjectBoardContent extends ConsumerWidget {
  final WidgetConfig config;

  const _ProjectBoardContent({required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardConfig = ProjectBoardWidgetConfig.fromWidgetConfig(config);
    final projectsAsync = ref.watch(projectsProvider);

    return projectsAsync.when(
      data: (projects) {
        final displayed = projects.take(boardConfig.maxProjects).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: displayed.isEmpty
                  ? const Center(
                      child: Text(
                        'No campaigns yet',
                        style: TextStyle(color: TavernColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: displayed.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: TavernColors.divider, height: 1),
                      itemBuilder: (context, i) => _ProjectTile(project: displayed[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 18, color: TavernColors.accent),
                label: const Text('New Campaign',
                    style: TextStyle(color: TavernColors.accent)),
                onPressed: () => _showCreateDialog(context, ref),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: TavernColors.accent)),
      error: (e, _) => Center(
        child: Text('Failed to load campaigns', style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CreateProjectDialog(ref: ref),
    );
  }
}

class _CreateProjectDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _CreateProjectDialog({required this.ref});

  @override
  ConsumerState<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<_CreateProjectDialog> {
  final _nameController = TextEditingController();
  String? _nameError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(projectServiceProvider).createProject({'name': name});
      ref.invalidate(projectsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        TavernSnackbar.showError(context, 'Failed to create campaign');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TavernDialog(
      title: 'New Campaign',
      onSave: _save,
      isSaving: _isSaving,
      content: TavernTextField(
        controller: _nameController,
        label: 'Name',
        required: true,
        errorText: _nameError,
        onChanged: (_) => setState(() => _nameError = null),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project project;

  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    try {
      final hex = project.color.replaceFirst('#', '');
      dotColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      dotColor = TavernColors.accent;
    }

    return ListTile(
      dense: true,
      leading: CircleAvatar(backgroundColor: dotColor, radius: 8),
      title: Text(project.name, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: project.deadline != null
          ? Text(
              'Due ${project.deadline!.toLocal().toString().split(' ').first}',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
    );
  }
}
