import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/widget_registry.dart';
import '../../models/entry.dart';
import '../../models/widget_config.dart';
import '../../providers/entry_provider.dart';
import '../../providers/project_provider.dart';
import '../../theme/tavern_theme.dart';
import '../../widgets/tavern_dialog.dart';
import '../../widgets/tavern_snackbar.dart';
import '../../widgets/tavern_text_field.dart';
import '../base_widget.dart';
import 'task_list_widget_config.dart';

class TaskListWidget extends BaseWidget {
  const TaskListWidget({super.key, required super.config});

  static void register() {
    WidgetRegistry.register(
      'task_list',
      (config) => TaskListWidget(config: config),
    );
  }

  @override
  String get widgetTitle => 'Tasks';

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    return _TaskListContent(config: config);
  }
}

class _TaskListContent extends ConsumerWidget {
  final WidgetConfig config;

  const _TaskListContent({required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tlConfig = TaskListWidgetConfig.fromWidgetConfig(config);
    final entriesAsync = ref.watch(entriesProvider);

    return entriesAsync.when(
      data: (entries) {
        final tasks = entries.where((e) {
          if (e.type != 'task') return false;
          if (!tlConfig.showCompleted && e.isCompleted) return false;
          if (tlConfig.projectFilter != null && e.projectId != tlConfig.projectFilter) return false;
          return true;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text('No tasks',
                          style: TextStyle(color: TavernColors.textSecondary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: TavernColors.divider, height: 1),
                      itemBuilder: (context, i) => _TaskTile(entry: tasks[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 18, color: TavernColors.accent),
                label: const Text('New Task',
                    style: TextStyle(color: TavernColors.accent)),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (ctx) => _CreateTaskDialog(ref: ref),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: TavernColors.accent)),
      error: (e, _) => Center(
        child: Text('Failed to load tasks', style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _CreateTaskDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _CreateTaskDialog({required this.ref});

  @override
  ConsumerState<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<_CreateTaskDialog> {
  final _titleController = TextEditingController();
  String? _titleError;
  String? _selectedProjectId;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(entryServiceProvider).createEntry({
        'type': 'task',
        'title': title,
        if (_selectedProjectId != null) 'project_id': _selectedProjectId,
        'is_completed': false,
      });
      ref.invalidate(entriesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        TavernSnackbar.showError(context, 'Failed to create task');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return TavernDialog(
      title: 'New Task',
      onSave: _save,
      isSaving: _isSaving,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TavernTextField(
            controller: _titleController,
            label: 'Title',
            required: true,
            errorText: _titleError,
            onChanged: (_) => setState(() => _titleError = null),
          ),
          const SizedBox(height: 16),
          projectsAsync.when(
            data: (projects) => DropdownButtonFormField<String>(
              value: _selectedProjectId,
              decoration: const InputDecoration(labelText: 'Campaign (optional)'),
              dropdownColor: TavernColors.surface,
              style: const TextStyle(color: TavernColors.textPrimary),
              items: projects
                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedProjectId = val),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  final Entry entry;

  const _TaskTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      leading: Checkbox(
        value: entry.isCompleted,
        activeColor: TavernColors.accent,
        checkColor: TavernColors.background,
        onChanged: (val) async {
          try {
            await ref.read(entryServiceProvider).updateEntry(
              entry.id,
              {'is_completed': val ?? false},
            );
            ref.invalidate(entriesProvider);
          } catch (e) {
            if (context.mounted) {
              TavernSnackbar.showError(context, 'Failed to update task');
            }
          }
        },
      ),
      title: Text(
        entry.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          decoration: entry.isCompleted ? TextDecoration.lineThrough : null,
          color: entry.isCompleted ? TavernColors.textSecondary : TavernColors.textPrimary,
        ),
      ),
    );
  }
}
