import 'package:health_ai_application/models/post_comment.dart';

class Post {
  final String id;
  final int authorUserId;
  final String authorName;
  final String authorHandle;
  final String? authorRole;
  final String? authorAvatarUrl;
  final String? authorAvatarEmoji;
  final String content;
  final DateTime createdAt;
  final String? mediaUrl;
  final String? mediaType;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final List<PostComment> comments;

  Post({
    required this.id,
    required this.authorUserId,
    required this.authorName,
    required this.authorHandle,
    required this.content,
    required this.createdAt,
    this.authorRole,
    this.authorAvatarUrl,
    this.authorAvatarEmoji,
    this.mediaUrl,
    this.mediaType,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final commentsJson = (json['comments'] as List<dynamic>?) ?? const [];
    return Post(
      id: (json['_id'] ?? json['id']).toString(),
      authorUserId: (json['authorUserId'] as num?)?.toInt() ?? 0,
      authorName: (json['authorName'] ?? '').toString(),
      authorHandle: (json['authorHandle'] ?? '').toString(),
      authorRole: json['authorRole']?.toString(),
      authorAvatarUrl: json['authorAvatarUrl']?.toString(),
      authorAvatarEmoji: json['authorAvatarEmoji']?.toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      mediaUrl: json['mediaUrl']?.toString(),
      mediaType: json['mediaType']?.toString(),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? commentsJson.length,
      likedByMe: json['likedByMe'] == true,
      comments: commentsJson
          .whereType<Map<String, dynamic>>()
          .map(PostComment.fromJson)
          .toList(),
    );
  }

  Post copyWith({
    String? newAuthorAvatarUrl,
    String? newAuthorAvatarEmoji,
    int? newLikeCount,
    int? newCommentCount,
    bool? newLikedByMe,
    List<PostComment>? newComments,
    String? newContent,
    String? newMediaUrl,
    String? newMediaType,
  }) {
    return Post(
      id: id,
      authorUserId: authorUserId,
      authorName: authorName,
      authorHandle: authorHandle,
      authorRole: authorRole,
      authorAvatarUrl: newAuthorAvatarUrl ?? authorAvatarUrl,
      authorAvatarEmoji: newAuthorAvatarEmoji ?? authorAvatarEmoji,
      content: newContent ?? content,
      createdAt: createdAt,
      mediaUrl: newMediaUrl ?? mediaUrl,
      mediaType: newMediaType ?? mediaType,
      likeCount: newLikeCount ?? likeCount,
      commentCount: newCommentCount ?? commentCount,
      likedByMe: newLikedByMe ?? likedByMe,
      comments: newComments ?? comments,
    );
  }
}

