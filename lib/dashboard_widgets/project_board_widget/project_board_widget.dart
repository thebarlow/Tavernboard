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

class _ProjectTile extends ConsumerWidget {
  final Project project;

  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: TavernColors.textSecondary, size: 18),
        color: TavernColors.surfaceElevated,
        onSelected: (value) async {
          if (value == 'edit') {
            showDialog<void>(
              context: context,
              builder: (ctx) => _EditProjectDialog(project: project, ref: ref),
            );
          } else if (value == 'delete') {
            try {
              await ref.read(projectServiceProvider).deleteProject(project.id);
              ref.invalidate(projectsProvider);
            } catch (e) {
              if (context.mounted) {
                TavernSnackbar.showError(context, 'Failed to delete campaign');
              }
            }
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

class _EditProjectDialog extends ConsumerStatefulWidget {
  final Project project;
  final WidgetRef ref;

  const _EditProjectDialog({required this.project, required this.ref});

  @override
  ConsumerState<_EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends ConsumerState<_EditProjectDialog> {
  late final TextEditingController _nameController;
  String? _nameError;
  bool _isSaving = false;

  static const _swatchColors = [
    '#C8860A', '#8B4513', '#5C3D1E', '#27AE60',
    '#2980B9', '#8E44AD', '#C0392B', '#F5E6C8',
  ];
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _selectedColor = widget.project.color;
  }

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
      await ref.read(projectServiceProvider).updateProject(widget.project.id, {
        'name': name,
        'color': _selectedColor,
      });
      ref.invalidate(projectsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) TavernSnackbar.showError(context, 'Failed to update campaign');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TavernDialog(
      title: 'Edit Campaign',
      onSave: _save,
      isSaving: _isSaving,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TavernTextField(
            controller: _nameController,
            label: 'Name',
            required: true,
            errorText: _nameError,
            onChanged: (_) => setState(() => _nameError = null),
          ),
          const SizedBox(height: 16),
          Text('Color', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _swatchColors.map((hex) {
              final color = Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
              final selected = _selectedColor == hex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: TavernColors.textPrimary, width: 2)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
