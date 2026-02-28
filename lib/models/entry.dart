enum EntryType { task, event, deadline }

enum RecurrenceFrequency { daily, weekly, monthly }

class RecurrenceRule {
  final RecurrenceFrequency frequency;

  const RecurrenceRule({required this.frequency});

  String encode() => frequency.name;

  factory RecurrenceRule.decode(String value) {
    final freq = RecurrenceFrequency.values.firstWhere(
      (f) => f.name == value,
    );
    return RecurrenceRule(frequency: freq);
  }
}

class Entry {
  final int? id;
  final int projectId;
  final EntryType type;
  final String title;
  final String? description;
  final DateTime? date;
  final String? startTime; // HH:mm format
  final String? endTime; // HH:mm format
  final int? colorOverride; // ARGB int, null = use project color
  final bool isCompleted;
  final int? reminderMinutes; // null = do not remind
  final RecurrenceRule? recurrenceRule;
  final DateTime createdAt;

  const Entry({
    this.id,
    required this.projectId,
    required this.type,
    required this.title,
    this.description,
    this.date,
    this.startTime,
    this.endTime,
    this.colorOverride,
    this.isCompleted = false,
    this.reminderMinutes,
    this.recurrenceRule,
    required this.createdAt,
  });

  Entry copyWith({
    int? id,
    int? projectId,
    EntryType? type,
    String? title,
    String? description,
    bool clearDescription = false,
    DateTime? date,
    bool clearDate = false,
    String? startTime,
    bool clearStartTime = false,
    String? endTime,
    bool clearEndTime = false,
    int? colorOverride,
    bool clearColorOverride = false,
    bool? isCompleted,
    int? reminderMinutes,
    bool clearReminder = false,
    RecurrenceRule? recurrenceRule,
    bool clearRecurrence = false,
    DateTime? createdAt,
  }) {
    return Entry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      title: title ?? this.title,
      description:
          clearDescription ? null : (description ?? this.description),
      date: clearDate ? null : (date ?? this.date),
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      colorOverride:
          clearColorOverride ? null : (colorOverride ?? this.colorOverride),
      isCompleted: isCompleted ?? this.isCompleted,
      reminderMinutes:
          clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
      recurrenceRule:
          clearRecurrence ? null : (recurrenceRule ?? this.recurrenceRule),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'type': type.name,
      'title': title,
      'description': description,
      'date': date?.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'color_override': colorOverride,
      'is_completed': isCompleted ? 1 : 0,
      'reminder_minutes': reminderMinutes,
      'recurrence_rule': recurrenceRule?.encode(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      type: EntryType.values.firstWhere((e) => e.name == map['type']),
      title: map['title'] as String,
      description: map['description'] as String?,
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : null,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      colorOverride: map['color_override'] as int?,
      isCompleted: (map['is_completed'] as int) == 1,
      reminderMinutes: map['reminder_minutes'] as int?,
      recurrenceRule: map['recurrence_rule'] != null
          ? RecurrenceRule.decode(map['recurrence_rule'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entry && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Entry(id: $id, title: $title, type: ${type.name})';
}
