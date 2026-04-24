class Reply {
  final String replyId;
  final String postId;
  final String? parentReplyId;
  final String authorId;
  final String authorUsername;
  final String content;
  final DateTime createdAt;
  final bool deleted;

  const Reply({
    required this.replyId,
    required this.postId,
    this.parentReplyId,
    required this.authorId,
    required this.authorUsername,
    required this.content,
    required this.createdAt,
    required this.deleted,
  });

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
        replyId: json['replyId'] as String,
        postId: json['postId'] as String,
        parentReplyId: json['parentReplyId'] as String?,
        authorId: json['authorId'] as String,
        authorUsername: json['authorUsername'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        deleted: json['deleted'] as bool,
      );
}
