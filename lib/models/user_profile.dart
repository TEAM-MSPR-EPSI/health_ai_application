class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String role;
  final String email;
  final String phone;
  final String? city;
  final String? country;
  final String? avatarUrl;
  final String? avatarEmoji;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.role,
    required this.email,
    required this.phone,
    this.city,
    this.country,
    this.avatarUrl,
    this.avatarEmoji,
  });

  String get displayName => '$firstName $lastName'.trim();
  bool get isAdmin => role == 'admin';

  bool get hasAvatarImage => (avatarUrl ?? '').isNotEmpty;
  bool get hasAvatarEmoji => (avatarEmoji ?? '').isNotEmpty;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['user_id'] as num?)?.toInt() ?? 0,
      firstName: (json['user_firstname'] ?? '').toString(),
      lastName: (json['user_lastname'] ?? '').toString(),
      username: (json['user_username'] ?? '').toString(),
      role: (json['user_role'] ?? 'user').toString(),
      email: (json['user_email'] ?? '').toString(),
      phone: (json['user_phone'] ?? '').toString(),
      city: json['user_city']?.toString(),
      country: json['user_country']?.toString(),
      avatarUrl: json['user_avatar_url']?.toString(),
      avatarEmoji: json['user_avatar_emoji']?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'user_firstname': firstName,
      'user_lastname': lastName,
      'user_username': username,
      'user_role': role,
      'user_phone': phone,
      'user_city': city,
      'user_country': country,
      'user_avatar_url': avatarUrl,
      'user_avatar_emoji': avatarEmoji,
    };
  }

  UserProfile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? username,
    String? role,
    String? email,
    String? phone,
    String? city,
    String? country,
    String? avatarUrl,
    String? avatarEmoji,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      country: country ?? this.country,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    );
  }
}

