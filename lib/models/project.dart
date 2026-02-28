class Project {
  final int? id;
  final String name;
  final int color; // ARGB int value
  final int categoryId;
  final DateTime? deadline;
  final DateTime createdAt;

  const Project({
    this.id,
    required this.name,
    required this.color,
    required this.categoryId,
    this.deadline,
    required this.createdAt,
  });

  Project copyWith({
    int? id,
    String? name,
    int? color,
    int? categoryId,
    DateTime? deadline,
    bool clearDeadline = false,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      categoryId: categoryId ?? this.categoryId,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
      'category_id': categoryId,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as int,
      categoryId: map['category_id'] as int,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Project && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Project(id: $id, name: $name)';
}
