import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/category.dart' as model;
import '../models/project.dart';
import '../providers/providers.dart';
import '../widgets/entry_tile.dart';
import '../widgets/add_entry_sheet.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final entriesAsync = ref.watch(entriesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text(
                  'Projects',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      _showAddProjectDialog(context, ref, categoriesAsync),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(77),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No projects yet',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(128),
                              ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => _showAddProjectDialog(
                              context, ref, categoriesAsync),
                          icon: const Icon(Icons.add),
                          label: const Text('Create project'),
                        ),
                      ],
                    ),
                  );
                }

                return entriesAsync.when(
                  data: (entries) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: projects.length,
                      itemBuilder: (context, i) {
                        final project = projects[i];
                        final projectEntries = entries
                            .where((e) => e.projectId == project.id)
                            .toList();
                        final taskCount = projectEntries.length;

                        return _ProjectCard(
                          project: project,
                          taskCount: taskCount,
                          entries: projectEntries,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<model.Category>> categoriesAsync,
  ) {
    showDialog(
      context: context,
      builder: (_) => const _AddProjectDialog(),
    );
  }
}

class _ProjectCard extends ConsumerStatefulWidget {
  final Project project;
  final int taskCount;
  final List entries;

  const _ProjectCard({
    required this.project,
    required this.taskCount,
    required this.entries,
  });

  @override
  ConsumerState<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends ConsumerState<_ProjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(project.color),
              radius: 16,
            ),
            title: Text(project.name),
            subtitle: Text(
              project.deadline != null
                  ? 'Deadline: ${DateFormat('MMM d').format(project.deadline!)}'
                  : 'No deadline',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${widget.taskCount} tasks'),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                ),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            if (widget.entries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No entries yet'),
              )
            else
              ...widget.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: EntryTile(entry: e),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (_) => AddEntrySheet(
                      initialProjectId: project.id,
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add entry'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddProjectDialog extends ConsumerStatefulWidget {
  const _AddProjectDialog();

  @override
  ConsumerState<_AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends ConsumerState<_AddProjectDialog> {
  final _nameController = TextEditingController();
  final _newCategoryController = TextEditingController();
  int? _selectedCategoryId;
  Color _selectedColor = Colors.blue;
  DateTime? _deadline;

  static const _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return AlertDialog(
      title: const Text('New Project'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Category
            Text('Category',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categories.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: [
                          ...categories.map((c) => ChoiceChip(
                                label: Text(c.name),
                                selected: _selectedCategoryId == c.id,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategoryId = c.id;
                                    _newCategoryController.clear();
                                  });
                                },
                              )),
                        ],
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newCategoryController,
                      decoration: InputDecoration(
                        hintText: categories.isEmpty
                            ? 'Enter a category (e.g. "YouTube")'
                            : 'Or type a new category...',
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        // Deselect chip when user starts typing a new one
                        if (_selectedCategoryId != null) {
                          setState(() => _selectedCategoryId = null);
                        }
                      },
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),

            // Color
            Text('Color',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colorOptions
                  .map((c) => GestureDetector(
                        onTap: () =>
                            setState(() => _selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: _selectedColor == c
                                ? Border.all(width: 3, color: Colors.black)
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Deadline
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() => _deadline = picked);
                }
              },
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                _deadline != null
                    ? 'Deadline: ${DateFormat('MMM d, yyyy').format(_deadline!)}'
                    : 'Set deadline (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project name')),
      );
      return;
    }

    // Auto-create category from text field if none selected
    int categoryId;
    if (_selectedCategoryId != null) {
      categoryId = _selectedCategoryId!;
    } else {
      final catName = _newCategoryController.text.trim();
      if (catName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select or enter a category'),
          ),
        );
        return;
      }
      categoryId = await ref
          .read(categoriesProvider.notifier)
          .add(model.Category(name: catName));
    }

    await ref.read(projectsProvider.notifier).add(
          Project(
            name: name,
            // ignore: deprecated_member_use
            color: _selectedColor.value,
            categoryId: categoryId,
            deadline: _deadline,
            createdAt: DateTime.now(),
          ),
        );

    if (mounted) Navigator.pop(context);
  }
}
