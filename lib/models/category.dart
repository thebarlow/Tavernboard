class Category {
  final String id;
  final String userId;
  final String name;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
  };
}
