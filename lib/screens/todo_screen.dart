import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import '../providers/providers.dart';
import '../theme/tavern_theme.dart';
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

    return Material(
      color: TavernTheme.parchment,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildFilters(context, projectsAsync, categoriesAsync),
            Expanded(child: _buildTaskList(context, todoAsync, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TavernTheme.parchment,
        border: Border(bottom: BorderSide(color: TavernTheme.border, width: 1)),
        boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      child: Row(
        children: [
          const Text(
            '✦',
            style: TextStyle(color: TavernTheme.gold, fontSize: 14),
          ),
          const SizedBox(width: 12),
          Text(
            "Today's Quest Log",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => const AddEntrySheet(initialType: EntryType.task),
              );
            },
            icon: const Icon(Icons.add, color: TavernTheme.inkMid),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    AsyncValue projectsAsync,
    AsyncValue categoriesAsync,
  ) {
    return Container(
      color: TavernTheme.parchment,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          projectsAsync.when(
            data: (projects) => _TavernFilterChip(
              label: _filterProjectId == null
                  ? 'By Campaign'
                  : (projects as List)
                          .where((p) => p.id == _filterProjectId)
                          .firstOrNull
                          ?.name ??
                      'By Campaign',
              isActive: _filterProjectId != null,
              onTap: () => _showProjectFilter(context, projects as List),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(width: 8),
          categoriesAsync.when(
            data: (categories) => _TavernFilterChip(
              label: _filterCategoryId == null
                  ? 'By Type'
                  : (categories as List)
                          .where((c) => c.id == _filterCategoryId)
                          .firstOrNull
                          ?.name ??
                      'By Type',
              isActive: _filterCategoryId != null,
              onTap: () => _showCategoryFilter(context, categories as List),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, AsyncValue todoAsync, WidgetRef ref) {
    return todoAsync.when(
      data: (groups) {
        final today = _applyFilters(groups.today, ref);
        final upcoming = _applyFilters(groups.upcoming, ref);
        final noDate = _applyFilters(groups.noDate, ref);

        if (today.isEmpty && upcoming.isEmpty && noDate.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚔', style: TextStyle(fontSize: 48, color: TavernTheme.inkLight)),
                const SizedBox(height: 12),
                Text(
                  'No quests today',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TavernTheme.inkLight,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            if (today.isNotEmpty) ...[
              const _QuestSectionHeader(title: "Today's Adventures"),
              ...today.map((e) => EntryTile(entry: e)),
            ],
            if (upcoming.isNotEmpty) ...[
              const _QuestSectionHeader(title: 'Upcoming Quests'),
              ...upcoming.map((e) => EntryTile(entry: e)),
            ],
            if (noDate.isNotEmpty) ...[
              const _QuestSectionHeader(title: 'Standing Orders'),
              ...noDate.map((e) => EntryTile(entry: e)),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  List<Entry> _applyFilters(List<Entry> entries, WidgetRef ref) {
    var filtered = entries;

    if (_filterProjectId != null) {
      filtered = filtered.where((e) => e.projectId == _filterProjectId).toList();
    }

    if (_filterCategoryId != null) {
      final projects = ref.read(projectsProvider).valueOrNull ?? [];
      final projectIds = projects
          .where((p) => p.categoryId == _filterCategoryId)
          .map((p) => p.id)
          .toSet();
      filtered = filtered.where((e) => projectIds.contains(e.projectId)).toList();
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
            title: const Text('All Campaigns'),
            onTap: () {
              setState(() => _filterProjectId = null);
              Navigator.pop(context);
            },
          ),
          ...projects.map((p) => ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(p.color),
                    borderRadius: BorderRadius.circular(2),
                  ),
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
            title: const Text('All Types'),
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

class _QuestSectionHeader extends StatelessWidget {
  final String title;
  const _QuestSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          const Text(
            '✦ ',
            style: TextStyle(color: TavernTheme.gold, fontSize: 10),
          ),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TavernTheme.inkMid,
                ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(color: TavernTheme.border, thickness: 1),
          ),
        ],
      ),
    );
  }
}

class _TavernFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TavernFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? TavernTheme.gold : TavernTheme.parchmentDeep,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? TavernTheme.goldLight
                : const Color(0x4D8B7255),
          ),
          boxShadow: isActive
              ? const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? TavernTheme.inkDark : TavernTheme.inkMid,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isActive ? TavernTheme.inkDark : TavernTheme.inkLight,
            ),
          ],
        ),
      ),
    );
  }
}
