import 'dart:convert';

enum RecurrenceFrequency { daily, weekly, monthly }

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int? interval;
  final DateTime? endDate;

  const RecurrenceRule({
    required this.frequency,
    this.interval,
    this.endDate,
  });

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    final freqStr = json['frequency'] as String;
    final frequency = RecurrenceFrequency.values.firstWhere(
      (f) => f.name == freqStr,
      orElse: () => RecurrenceFrequency.daily,
    );
    return RecurrenceRule(
      frequency: frequency,
      interval: json['interval'] as int?,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'frequency': frequency.name,
    if (interval != null) 'interval': interval,
    if (endDate != null) 'end_date': endDate!.toIso8601String().split('T').first,
  };
}

class Entry {
  final String id;
  final String userId;
  final String? projectId;
  final String type;
  final String title;
  final String? description;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final String? colorOverride;
  final bool isCompleted;
  final DateTime? reminderTime;
  final RecurrenceRule? recurrenceRule;
  final DateTime createdAt;

  const Entry({
    required this.id,
    required this.userId,
    this.projectId,
    required this.type,
    required this.title,
    this.description,
    this.date,
    this.startTime,
    this.endTime,
    this.colorOverride,
    required this.isCompleted,
    this.reminderTime,
    this.recurrenceRule,
    required this.createdAt,
  });

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    projectId: json['project_id'] as String?,
    type: json['type'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    startTime: json['start_time'] as String?,
    endTime: json['end_time'] as String?,
    colorOverride: json['color_override'] as String?,
    isCompleted: json['is_completed'] as bool? ?? false,
    reminderTime: json['reminder_time'] != null ? DateTime.parse(json['reminder_time'] as String) : null,
    recurrenceRule: json['recurrence_rule'] != null
        ? RecurrenceRule.fromJson(
            jsonDecode(json['recurrence_rule'] as String) as Map<String, dynamic>)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    if (projectId != null) 'project_id': projectId,
    'type': type,
    'title': title,
    if (description != null) 'description': description,
    if (date != null) 'date': date!.toIso8601String().split('T').first,
    if (startTime != null) 'start_time': startTime,
    if (endTime != null) 'end_time': endTime,
    if (colorOverride != null) 'color_override': colorOverride,
    'is_completed': isCompleted,
    if (reminderTime != null) 'reminder_time': reminderTime!.toIso8601String(),
    if (recurrenceRule != null) 'recurrence_rule': jsonEncode(recurrenceRule!.toJson()),
    'created_at': createdAt.toIso8601String(),
  };

  Entry copyWith({
    String? projectId,
    String? type,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? colorOverride,
    bool? isCompleted,
    DateTime? reminderTime,
    RecurrenceRule? recurrenceRule,
  }) => Entry(
    id: id,
    userId: userId,
    projectId: projectId ?? this.projectId,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description ?? this.description,
    date: date ?? this.date,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    colorOverride: colorOverride ?? this.colorOverride,
    isCompleted: isCompleted ?? this.isCompleted,
    reminderTime: reminderTime ?? this.reminderTime,
    recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    createdAt: createdAt,
  );
}
