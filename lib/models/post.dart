class Post {
  final String id;
  final String authorName;
  final String authorHandle;
  final String content;
  final DateTime createdAt;
  // Optional media attached to the post. Path is a local file path on device.
  final String? mediaPath;
  // 'image' or 'video'
  final String? mediaType;

  Post({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.content,
    required this.createdAt,
    this.mediaPath,
    this.mediaType,
  });
}

