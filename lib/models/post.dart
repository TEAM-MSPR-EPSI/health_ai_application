class Post {
  final String id;
  final String authorName;
  final String authorHandle;
  final String content;
  final DateTime createdAt;
  // Optional media URL served by backend.
  final String? mediaUrl;
  // 'image' or 'video'
  final String? mediaType;

  Post({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.content,
    required this.createdAt,
    this.mediaUrl,
    this.mediaType,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['_id'] ?? json['id']).toString(),
      authorName: (json['authorName'] ?? '').toString(),
      authorHandle: (json['authorHandle'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      mediaUrl: json['mediaUrl']?.toString(),
      mediaType: json['mediaType']?.toString(),
    );
  }
}

