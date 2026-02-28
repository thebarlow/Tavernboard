enum ExceptionAction { skip, reschedule }

class RecurrenceException {
  final int? id;
  final int entryId;
  final DateTime originalDate;
  final ExceptionAction action;
  final DateTime? newDate;

  const RecurrenceException({
    this.id,
    required this.entryId,
    required this.originalDate,
    required this.action,
    this.newDate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'entry_id': entryId,
      'original_date': originalDate.toIso8601String(),
      'action': action.name,
      'new_date': newDate?.toIso8601String(),
    };
  }

  factory RecurrenceException.fromMap(Map<String, dynamic> map) {
    return RecurrenceException(
      id: map['id'] as int?,
      entryId: map['entry_id'] as int,
      originalDate: DateTime.parse(map['original_date'] as String),
      action: ExceptionAction.values.firstWhere(
        (a) => a.name == map['action'],
      ),
      newDate: map['new_date'] != null
          ? DateTime.parse(map['new_date'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'RecurrenceException(id: $id, entryId: $entryId, action: ${action.name})';
}
