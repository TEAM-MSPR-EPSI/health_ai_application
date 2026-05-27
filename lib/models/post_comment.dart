class PostComment {
  final String id;
  final int authorUserId;
  final String authorName;
  final String authorHandle;
  final String? authorRole;
  final String? authorAvatarUrl;
  final String? authorAvatarEmoji;
  final String content;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.authorUserId,
    required this.authorName,
    required this.authorHandle,
    required this.content,
    required this.createdAt,
    this.authorRole,
    this.authorAvatarUrl,
    this.authorAvatarEmoji,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic> ? json['author'] as Map<String, dynamic> : <String, dynamic>{};
    return PostComment(
      id: (json['_id'] ?? json['id']).toString(),
      authorUserId: (json['authorUserId'] as num?)?.toInt() ?? 0,
      authorName: (json['authorName'] ?? '').toString(),
      authorHandle: (json['authorHandle'] ?? '').toString(),
      authorRole: json['authorRole']?.toString(),
      authorAvatarUrl: (json['authorAvatarUrl'] ?? author['avatarUrl'])?.toString(),
      authorAvatarEmoji: (json['authorAvatarEmoji'] ?? author['avatarEmoji'])?.toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
