import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import '../providers/providers.dart';
import '../widgets/entry_tile.dart';
import '../widgets/add_entry_sheet.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  int? _filterProjectId;
  int? _filterCategoryId;

  @override
  Widget build(BuildContext context) {
    final todoAsync = ref.watch(todoEntriesProvider);
    final projectsAsync = ref.watch(projectsProvider);
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
                  'To-Do',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => const AddEntrySheet(
                        initialType: EntryType.task,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Project filter
                projectsAsync.when(
                  data: (projects) => _FilterChip(
                    label: _filterProjectId == null
                        ? 'Project'
                        : projects
                            .where((p) => p.id == _filterProjectId)
                            .firstOrNull
                            ?.name ?? 'Project',
                    isActive: _filterProjectId != null,
                    onTap: () => _showProjectFilter(context, projects),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(width: 8),
                // Category filter
                categoriesAsync.when(
                  data: (categories) => _FilterChip(
                    label: _filterCategoryId == null
                        ? 'Category'
                        : categories
                            .where((c) => c.id == _filterCategoryId)
                            .firstOrNull
                            ?.name ?? 'Category',
                    isActive: _filterCategoryId != null,
                    onTap: () => _showCategoryFilter(context, categories),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),

          // Task groups
          Expanded(
            child: todoAsync.when(
              data: (groups) {
                final today = _applyFilters(groups.today, ref);
                final upcoming = _applyFilters(groups.upcoming, ref);
                final noDate = _applyFilters(groups.noDate, ref);

                if (today.isEmpty && upcoming.isEmpty && noDate.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks',
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
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (today.isNotEmpty) ...[
                      _SectionHeader(title: 'TODAY'),
                      ...today.map((e) => EntryTile(entry: e)),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      _SectionHeader(title: 'UPCOMING'),
                      ...upcoming.map((e) => EntryTile(entry: e)),
                    ],
                    if (noDate.isNotEmpty) ...[
                      _SectionHeader(title: 'NO DATE'),
                      ...noDate.map((e) => EntryTile(entry: e)),
                    ],
                  ],
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

  List<Entry> _applyFilters(List<Entry> entries, WidgetRef ref) {
    var filtered = entries;

    if (_filterProjectId != null) {
      filtered = filtered
          .where((e) => e.projectId == _filterProjectId)
          .toList();
    }

    if (_filterCategoryId != null) {
      final projects = ref.read(projectsProvider).valueOrNull ?? [];
      final projectIds = projects
          .where((p) => p.categoryId == _filterCategoryId)
          .map((p) => p.id)
          .toSet();
      filtered = filtered
          .where((e) => projectIds.contains(e.projectId))
          .toList();
    }

    return filtered;
  }

  void _showProjectFilter(BuildContext context, List projects) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('All Projects'),
            onTap: () {
              setState(() => _filterProjectId = null);
              Navigator.pop(context);
            },
          ),
          ...projects.map((p) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(p.color),
                  radius: 12,
                ),
                title: Text(p.name),
                onTap: () {
                  setState(() => _filterProjectId = p.id);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showCategoryFilter(BuildContext context, List categories) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('All Categories'),
            onTap: () {
              setState(() => _filterCategoryId = null);
              Navigator.pop(context);
            },
          ),
          ...categories.map((c) => ListTile(
                title: Text(c.name),
                onTap: () {
                  setState(() => _filterCategoryId = c.id);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 18,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ],
      ),
      onPressed: onTap,
      backgroundColor: isActive
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
    );
  }
}
