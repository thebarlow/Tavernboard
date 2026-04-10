class Project {
  final String id;
  final String userId;
  final String name;
  final String color;
  final String? categoryId;
  final DateTime? deadline;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    this.categoryId,
    this.deadline,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    color: json['color'] as String? ?? '#C8860A',
    categoryId: json['category_id'] as String?,
    deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'color': color,
    if (categoryId != null) 'category_id': categoryId,
    if (deadline != null) 'deadline': deadline!.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  Project copyWith({
    String? name,
    String? color,
    String? categoryId,
    DateTime? deadline,
  }) => Project(
    id: id,
    userId: userId,
    name: name ?? this.name,
    color: color ?? this.color,
    categoryId: categoryId ?? this.categoryId,
    deadline: deadline ?? this.deadline,
    createdAt: createdAt,
  );
}
