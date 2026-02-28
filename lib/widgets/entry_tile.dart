import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import '../providers/providers.dart';
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
      opacity: entry.isCompleted ? 0.5 : 1.0,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: displayColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            if (entry.type == EntryType.task)
              GestureDetector(
                onTap: () {
                  ref.read(entriesProvider.notifier).toggleComplete(entry);
                },
                child: Icon(
                  typeIcon,
                  size: 22,
                  color: displayColor,
                ),
              )
            else
              Icon(typeIcon, size: 22, color: displayColor),
          ],
        ),
        title: Text(
          entry.title,
          style: TextStyle(
            decoration:
                entry.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: entry.startTime != null ? Text(entry.startTime!) : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: displayColor.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            typeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: displayColor,
            ),
          ),
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => AddEntrySheet(existingEntry: entry),
          );
        },
      ),
    );
  }
}
