class Post {
  final String postId;
  final String authorId;
  final String authorUsername;
  final String content;
  final List<String> topics;
  final int repliesCount;
  final int bookmarksCount;
  final bool isPublic;
  final bool isNSFW;
  final List<dynamic> attachments;
  final bool hasAudioAttachment;
  final String audioAttachmentGenre;
  final DateTime createdAt;
  final bool deleted;

  const Post({
    required this.postId,
    required this.authorId,
    required this.authorUsername,
    required this.content,
    required this.topics,
    required this.repliesCount,
    required this.bookmarksCount,
    required this.isPublic,
    required this.isNSFW,
    required this.attachments,
    required this.hasAudioAttachment,
    required this.audioAttachmentGenre,
    required this.createdAt,
    required this.deleted,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        postId: (json['postId'] as String?) ?? '',
        authorId: (json['authorId'] as String?) ?? '',
        authorUsername: (json['authorUsername'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
        topics: (json['topics'] as List?)?.cast<String>() ?? [],
        repliesCount: (json['repliesCount'] as int?) ?? 0,
        bookmarksCount: (json['bookmarksCount'] as int?) ?? 0,
        isPublic: (json['isPublic'] as bool?) ?? true,
        isNSFW: (json['isNSFW'] as bool?) ?? false,
        attachments: (json['attachments'] as List?) ?? [],
        hasAudioAttachment: (json['hasAudioAttachment'] as bool?) ?? false,
        audioAttachmentGenre: (json['audioAttachmentGenre'] as String?) ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.fromMillisecondsSinceEpoch(0),
        deleted: (json['deleted'] as bool?) ?? false,
      );
}
