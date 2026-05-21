class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Pengguna',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Only includes fields that belong in the profiles table.
  /// Email is NOT included because it lives in Supabase Auth, not profiles.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
  UserProfileModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }
}
