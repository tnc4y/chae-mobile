class CommentUser {
  final String username;
  final String? displayName;
  final String? avatarUrl;

  const CommentUser({
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) => CommentUser(
    username: json['username'] as String? ?? '',
    displayName: json['display_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
  );

  String get displayedName =>
      displayName?.isNotEmpty == true ? displayName! : username;
}

class Comment {
  final String id;
  final String content;
  final bool isSpoiler;
  final bool isPinned;
  final int likeCount;
  final int replyCount;
  final DateTime createdAt;
  final CommentUser user;
  final String? parentId;

  const Comment({
    required this.id,
    required this.content,
    required this.isSpoiler,
    required this.isPinned,
    required this.likeCount,
    required this.replyCount,
    required this.createdAt,
    required this.user,
    this.parentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] as String,
    content: json['content'] as String? ?? '',
    isSpoiler: json['is_spoiler'] as bool? ?? false,
    isPinned: json['is_pinned'] as bool? ?? false,
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    user: CommentUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    parentId: json['parent_id'] as String?,
  );
}
