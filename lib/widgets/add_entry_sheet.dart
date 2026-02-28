import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';

import '../providers/providers.dart';

class AddEntrySheet extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final int? initialProjectId;
  final EntryType? initialType;
  final Entry? existingEntry;

  const AddEntrySheet({
    super.key,
    this.initialDate,
    this.initialProjectId,
    this.initialType,
    this.existingEntry,
  });

  @override
  ConsumerState<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends ConsumerState<AddEntrySheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late EntryType _type;
  int? _projectId;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _reminderMinutes; // null = do not remind
  RecurrenceFrequency? _recurrenceFrequency;

  bool get _isEditing => widget.existingEntry != null;

  static const _reminderOptions = <int?, String>{
    null: 'Do not remind',
    5: '5 minutes before',
    15: '15 minutes before',
    30: '30 minutes before',
    60: '1 hour before',
    1440: '1 day before',
  };

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final e = widget.existingEntry!;
      _titleController.text = e.title;
      _descriptionController.text = e.description ?? '';
      _type = e.type;
      _projectId = e.projectId;
      _date = e.date;
      _startTime = _parseTime(e.startTime);
      _endTime = _parseTime(e.endTime);
      _reminderMinutes = e.reminderMinutes;
      _recurrenceFrequency = e.recurrenceRule?.frequency;
    } else {
      _type = widget.initialType ?? EntryType.task;
      _projectId = widget.initialProjectId;
      _date = widget.initialDate;
    }
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Entry' : 'New Entry',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      if (_isEditing)
                        IconButton(
                          onPressed: _delete,
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Type selector
              SegmentedButton<EntryType>(
                segments: const [
                  ButtonSegment(
                    value: EntryType.task,
                    label: Text('Task'),
                    icon: Icon(Icons.check_box_outline_blank),
                  ),
                  ButtonSegment(
                    value: EntryType.event,
                    label: Text('Event'),
                    icon: Icon(Icons.event),
                  ),
                  ButtonSegment(
                    value: EntryType.deadline,
                    label: Text('Deadline'),
                    icon: Icon(Icons.flag),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) =>
                    setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),

              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                autofocus: !_isEditing,
              ),
              const SizedBox(height: 12),

              // Description
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Project picker
              projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return const Text('Create a project first');
                  }
                  return DropdownButtonFormField<int>(
                    value: _projectId,
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      border: OutlineInputBorder(),
                    ),
                    items: projects
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(p.color),
                                    radius: 8,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(p.name),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _projectId = v),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 12),

              // Date & Time row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _date != null
                            ? DateFormat('MMM d').format(_date!)
                            : 'Date',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickStartTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(
                        _startTime != null
                            ? _startTime!.format(context)
                            : 'Start',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickEndTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(
                        _endTime != null
                            ? _endTime!.format(context)
                            : 'End',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recurrence
              DropdownButtonFormField<RecurrenceFrequency?>(
                value: _recurrenceFrequency,
                decoration: const InputDecoration(
                  labelText: 'Repeat',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('None')),
                  DropdownMenuItem(
                    value: RecurrenceFrequency.daily,
                    child: Text('Daily'),
                  ),
                  DropdownMenuItem(
                    value: RecurrenceFrequency.weekly,
                    child: Text('Weekly'),
                  ),
                  DropdownMenuItem(
                    value: RecurrenceFrequency.monthly,
                    child: Text('Monthly'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _recurrenceFrequency = v),
              ),
              const SizedBox(height: 12),

              // Reminder
              DropdownButtonFormField<int?>(
                value: _reminderMinutes,
                decoration: const InputDecoration(
                  labelText: 'Reminder',
                  border: OutlineInputBorder(),
                ),
                items: _reminderOptions.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _reminderMinutes = v),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(_isEditing ? 'Update' : 'Save'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title and select a project'),
        ),
      );
      return;
    }

    final entry = Entry(
      id: widget.existingEntry?.id,
      projectId: _projectId!,
      type: _type,
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      date: _date,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      isCompleted: widget.existingEntry?.isCompleted ?? false,
      reminderMinutes: _reminderMinutes,
      recurrenceRule: _recurrenceFrequency != null
          ? RecurrenceRule(frequency: _recurrenceFrequency!)
          : null,
      createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await ref.read(entriesProvider.notifier).updateItem(entry);
    } else {
      await ref.read(entriesProvider.notifier).add(entry);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(entriesProvider.notifier)
          .delete(widget.existingEntry!.id!);
      if (mounted) Navigator.pop(context);
    }
  }
}
