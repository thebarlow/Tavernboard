class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (displayName != null) 'display_name': displayName,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
  };
}
