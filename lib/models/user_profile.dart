class UserProfile {
  final String name;
  final String username;
  final String bio;

  const UserProfile({
    required this.name,
    required this.username,
    required this.bio,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? bio,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
    );
  }
}

