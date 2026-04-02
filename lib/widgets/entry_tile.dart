import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import '../providers/providers.dart';
import '../theme/tavern_theme.dart';
import '../widgets/add_entry_sheet.dart';

class EntryTile extends ConsumerWidget {
  final Entry entry;
  const EntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    final projectColor = projectsAsync.whenOrNull(
      data: (projects) {
        final project =
            projects.where((p) => p.id == entry.projectId).firstOrNull;
        return project != null ? Color(project.color) : null;
      },
    );

    final displayColor = entry.colorOverride != null
        ? Color(entry.colorOverride!)
        : projectColor ?? Colors.grey;

    final typeIcon = switch (entry.type) {
      EntryType.task => entry.isCompleted
          ? Icons.check_box
          : Icons.check_box_outline_blank,
      EntryType.event => Icons.event,
      EntryType.deadline => Icons.flag,
    };

    final typeLabel = switch (entry.type) {
      EntryType.task => 'T',
      EntryType.event => 'E',
      EntryType.deadline => 'D',
    };

    return Opacity(
      opacity: entry.isCompleted ? 0.45 : 1.0,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => AddEntrySheet(existingEntry: entry),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: TavernTheme.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Gem dot + checkbox area
              SizedBox(
                width: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotated gem indicator
                    Transform.rotate(
                      angle: 0.785, // 45 degrees
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              displayColor.withAlpha(200),
                              displayColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: displayColor.withAlpha(80),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (entry.type == EntryType.task)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () {
                            ref.read(entriesProvider.notifier).toggleComplete(entry);
                          },
                          child: Icon(
                            typeIcon,
                            size: 16,
                            color: displayColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'serif',
                            fontWeight: FontWeight.w600,
                            decoration: entry.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    if (entry.startTime != null)
                      Text(
                        entry.startTime!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: displayColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: displayColor.withAlpha(60)),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: displayColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
