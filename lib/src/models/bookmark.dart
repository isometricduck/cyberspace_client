enum BookmarkType { post, reply }

class Bookmark {
  final String bookmarkId;
  final BookmarkType type;
  final String? postId;
  final String? replyId;
  final DateTime? createdAt;

  const Bookmark({
    required this.bookmarkId,
    required this.type,
    this.postId,
    this.replyId,
    this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        bookmarkId: json['bookmarkId'] as String,
        type: (json['type'] as String) == 'reply'
            ? BookmarkType.reply
            : BookmarkType.post,
        postId: json['postId'] as String?,
        replyId: json['replyId'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}
