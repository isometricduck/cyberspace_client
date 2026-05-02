enum NotificationType {
  reply('reply'),
  newPostFollowing('new_post_following'),
  bookmark('bookmark'),
  poke('poke'),
  guildNewThread('guild_new_thread'),
  replyMention('reply_mention'),
  supporterGranted('supporter_granted'),
  threadReply('thread_reply'),
  unknown('unknown');

  final String value;

  const NotificationType(this.value);

  static NotificationType fromJson(String value) => NotificationType.values
      .firstWhere((type) => type.value == value, orElse: () => unknown);
}

class Notification {
  final String notificationId;
  final NotificationType type;
  final String rawType;
  final bool read;
  final Map<String, dynamic> data;
  final String? actorId;
  final String? actorUsername;
  final String? targetType;
  final String? targetId;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  const Notification({
    required this.notificationId,
    required this.type,
    required this.rawType,
    required this.read,
    required this.data,
    this.actorId,
    this.actorUsername,
    this.targetType,
    this.targetId,
    this.metadata,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String;

    return Notification(
      notificationId: json['id'] as String,
      type: NotificationType.fromJson(rawType),
      rawType: rawType,
      read: json['read'] as bool,
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      actorId: json['actorId'] as String?,
      actorUsername: json['actorUsername'] as String?,
      targetType: json['targetType'] as String?,
      targetId: json['targetId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
