import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/category.dart' as model;
import '../models/project.dart';
import '../providers/providers.dart';
import '../theme/tavern_theme.dart';
import '../widgets/entry_tile.dart';
import '../widgets/add_entry_sheet.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final entriesAsync = ref.watch(entriesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Material(
      color: TavernTheme.parchment,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, categoriesAsync),
            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚔', style: TextStyle(fontSize: 56, color: TavernTheme.inkLight)),
                          const SizedBox(height: 16),
                          Text(
                            'No campaigns yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: TavernTheme.inkLight,
                                ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () =>
                                _showAddProjectDialog(context, ref, categoriesAsync),
                            icon: const Icon(Icons.add),
                            label: const Text('Start a Campaign'),
                          ),
                        ],
                      ),
                    );
                  }

                  return entriesAsync.when(
                    data: (entries) {
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: projects.length,
                        itemBuilder: (context, i) {
                          final project = projects[i];
                          final projectEntries =
                              entries.where((e) => e.projectId == project.id).toList();
                          return _CampaignCard(
                            project: project,
                            taskCount: projectEntries.length,
                            entries: projectEntries,
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<model.Category>> categoriesAsync,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: TavernTheme.parchment,
        border: Border(bottom: BorderSide(color: TavernTheme.border, width: 1)),
        boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      child: Row(
        children: [
          const Text('⚔', style: TextStyle(color: TavernTheme.gold, fontSize: 18)),
          const SizedBox(width: 12),
          Text('Active Campaigns', style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          IconButton(
            onPressed: () => _showAddProjectDialog(context, ref, categoriesAsync),
            icon: const Icon(Icons.add, color: TavernTheme.inkMid),
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

class _CampaignCard extends ConsumerStatefulWidget {
  final Project project;
  final int taskCount;
  final List entries;

  const _CampaignCard({
    required this.project,
    required this.taskCount,
    required this.entries,
  });

  @override
  ConsumerState<_CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends ConsumerState<_CampaignCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final projectColor = Color(project.color);
    final hasDeadline = project.deadline != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TavernTheme.parchmentDeep,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: TavernTheme.border),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 10, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Card header with iron-nail dot
          Stack(
            alignment: Alignment.topCenter,
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Row(
                    children: [
                      // Gem-colored project indicator
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              projectColor.withAlpha(200),
                              projectColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: projectColor.withAlpha(100),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${widget.taskCount} quest${widget.taskCount == 1 ? '' : 's'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (hasDeadline) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: TavernTheme.deadlineRed.withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: TavernTheme.deadlineRed.withAlpha(50),
                                      ),
                                    ),
                                    child: Text(
                                      '⏰ ${DateFormat('MMM d').format(project.deadline!)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: TavernTheme.deadlineRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: TavernTheme.inkLight,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              // Iron nail
              Positioned(
                top: 6,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      colors: [Color(0xFF5A5A5A), Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x99000000), blurRadius: 3, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_expanded) ...[
            const Divider(height: 1, color: TavernTheme.border),
            if (widget.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No entries yet',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
                    builder: (_) => AddEntrySheet(initialProjectId: project.id),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Quest'),
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
  Color _selectedColor = TavernTheme.gemAmber;
  DateTime? _deadline;

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
      title: const Text('New Campaign'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Campaign name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            Text('Category', style: Theme.of(context).textTheme.labelLarge),
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

            Text('Gem Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: TavernTheme.gemPalette
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [c.withAlpha(200), c],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: _selectedColor == c
                                ? Border.all(width: 3, color: TavernTheme.inkDark)
                                : Border.all(color: TavernTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: c.withAlpha(80),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
        const SnackBar(content: Text('Please enter a campaign name')),
      );
      return;
    }

    int categoryId;
    if (_selectedCategoryId != null) {
      categoryId = _selectedCategoryId!;
    } else {
      final catName = _newCategoryController.text.trim();
      if (catName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select or enter a category')),
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
