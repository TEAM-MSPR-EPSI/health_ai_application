class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String? city;
  final String? country;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    this.city,
    this.country,
  });

  String get displayName => '$firstName $lastName'.trim();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['user_id'] as num?)?.toInt() ?? 0,
      firstName: (json['user_firstname'] ?? '').toString(),
      lastName: (json['user_lastname'] ?? '').toString(),
      username: (json['user_username'] ?? '').toString(),
      email: (json['user_email'] ?? '').toString(),
      phone: (json['user_phone'] ?? '').toString(),
      city: json['user_city']?.toString(),
      country: json['user_country']?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'user_firstname': firstName,
      'user_lastname': lastName,
      'user_username': username,
      'user_phone': phone,
      'user_city': city,
      'user_country': country,
    };
  }

  UserProfile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? city,
    String? country,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}

