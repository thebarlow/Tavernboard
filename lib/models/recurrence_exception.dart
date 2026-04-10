enum ExceptionAction { skip, reschedule }

class RecurrenceException {
  final String id;
  final String entryId;
  final DateTime originalDate;
  final ExceptionAction action;
  final DateTime? newDate;

  const RecurrenceException({
    required this.id,
    required this.entryId,
    required this.originalDate,
    required this.action,
    this.newDate,
  });

  factory RecurrenceException.fromJson(Map<String, dynamic> json) {
    final actionStr = json['action'] as String;
    final action = actionStr == 'skip' ? ExceptionAction.skip : ExceptionAction.reschedule;
    return RecurrenceException(
      id: json['id'] as String,
      entryId: json['entry_id'] as String,
      originalDate: DateTime.parse(json['original_date'] as String),
      action: action,
      newDate: json['new_date'] != null ? DateTime.parse(json['new_date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'entry_id': entryId,
    'original_date': originalDate.toIso8601String().split('T').first,
    'action': action == ExceptionAction.skip ? 'skip' : 'reschedule',
    if (newDate != null) 'new_date': newDate!.toIso8601String().split('T').first,
  };
}
