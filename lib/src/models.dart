// ─── Auth ────────────────────────────────────────────────────────────────────

class AuthTokens {
  final String idToken;
  final String refreshToken;
  final String rtdbToken;

  const AuthTokens({
    required this.idToken,
    required this.refreshToken,
    required this.rtdbToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        idToken: json['idToken'] as String,
        refreshToken: json['refreshToken'] as String,
        rtdbToken: json['rtdbToken'] as String,
      );
}

class RefreshedTokens {
  final String idToken;
  final String rtdbToken;

  const RefreshedTokens({required this.idToken, required this.rtdbToken});

  factory RefreshedTokens.fromJson(Map<String, dynamic> json) =>
      RefreshedTokens(
        idToken: json['idToken'] as String,
        rtdbToken: json['rtdbToken'] as String,
      );
}

// ─── Pagination ───────────────────────────────────────────────────────────────

class PagedResult<T> {
  final List<T> data;

  /// Opaque cursor for the next page. `null` when there are no more results.
  final String? cursor;

  const PagedResult({required this.data, required this.cursor});
}

// ─── Posts (Entries) ──────────────────────────────────────────────────────────

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
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.fromMillisecondsSinceEpoch(0),
        deleted: (json['deleted'] as bool?) ?? false,
      );
}

// ─── Replies ──────────────────────────────────────────────────────────────────

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

// ─── Users ────────────────────────────────────────────────────────────────────

class UserProfile {
  final String userId;
  final String username;
  final String? displayName;
  final String? bio;
  final String? pinnedPostId;
  final String? websiteUrl;
  final String? websiteName;
  final String? websiteImageUrl;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? locationName;
  final DateTime? createdAt;

  const UserProfile({
    required this.userId,
    required this.username,
    this.displayName,
    this.bio,
    this.pinnedPostId,
    this.websiteUrl,
    this.websiteName,
    this.websiteImageUrl,
    this.locationLatitude,
    this.locationLongitude,
    this.locationName,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        userId: json['userId'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String?,
        bio: json['bio'] as String?,
        pinnedPostId: json['pinnedPostId'] as String?,
        websiteUrl: json['websiteUrl'] as String?,
        websiteName: json['websiteName'] as String?,
        websiteImageUrl: json['websiteImageUrl'] as String?,
        locationLatitude: (json['locationLatitude'] as num?)?.toDouble(),
        locationLongitude: (json['locationLongitude'] as num?)?.toDouble(),
        locationName: json['locationName'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}

// ─── Bookmarks ────────────────────────────────────────────────────────────────

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

// ─── Follows ──────────────────────────────────────────────────────────────────

class Follow {
  final String followId;
  final String followerId;
  final String followedId;
  final String? followerUsername;
  final String? followedUsername;
  final DateTime? createdAt;

  const Follow({
    required this.followId,
    required this.followerId,
    required this.followedId,
    this.followerUsername,
    this.followedUsername,
    this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) => Follow(
        followId: json['followId'] as String,
        followerId: json['followerId'] as String,
        followedId: json['followedId'] as String,
        followerUsername: json['followerUsername'] as String?,
        followedUsername: json['followedUsername'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}

// ─── Notifications ────────────────────────────────────────────────────────────

class Notification {
  final String notificationId;
  final String type;
  final bool read;
  final Map<String, dynamic> data;
  final DateTime? createdAt;

  const Notification({
    required this.notificationId,
    required this.type,
    required this.read,
    required this.data,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        notificationId: json['notificationId'] as String,
        type: json['type'] as String,
        read: json['read'] as bool,
        data: (json['data'] as Map<String, dynamic>?) ?? {},
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}

// ─── Notes ────────────────────────────────────────────────────────────────────

class Note {
  final String noteId;
  final String content;
  final List<String> topics;
  final int revision;
  final DateTime? createdAt;
  final bool deleted;

  const Note({
    required this.noteId,
    required this.content,
    required this.topics,
    required this.revision,
    this.createdAt,
    required this.deleted,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        noteId: json['noteId'] as String,
        content: json['content'] as String,
        topics: json['topics'] != null
            ? (json['topics'] as List).cast<String>()
            : [],
        revision: json['revision'] as int,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        deleted: (json['deleted'] as bool?) ?? false,
      );
}

// ─── Topics ───────────────────────────────────────────────────────────────────

class Topic {
  final String slug;
  final int postCount;

  const Topic({required this.slug, required this.postCount});

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        slug: json['slug'] as String,
        postCount: (json['postCount'] as num).toInt(),
      );
}

// ─── Settings ─────────────────────────────────────────────────────────────────

class NotificationSettings {
  final bool? bookmark;
  final bool? reply;
  final bool? poke;

  const NotificationSettings({this.bookmark, this.reply, this.poke});

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        bookmark: json['bookmark'] as bool?,
        reply: json['reply'] as bool?,
        poke: json['poke'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        if (bookmark != null) 'bookmark': bookmark,
        if (reply != null) 'reply': reply,
        if (poke != null) 'poke': poke,
      };
}

class Settings {
  final NotificationSettings? notifications;
  final bool? filterNSFW;
  final bool? showFollowerCount;
  final bool? hideImagesInFeed;
  final bool? hideAudioInFeed;
  final bool? autoWatchOnReply;
  final dynamic keyboardBindings;
  final String? keyboardPreset;
  final Map<String, dynamic>? mutedUsersByRoom;
  final String? iconTheme;
  final List<String>? followedTopics;
  final List<String>? mutedTopics;
  final int? imagePixelSize;
  final String? timeDisplayFormat;
  final bool? useLegacyMenuOrder;
  final bool? defaultPublicPost;

  const Settings({
    this.notifications,
    this.filterNSFW,
    this.showFollowerCount,
    this.hideImagesInFeed,
    this.hideAudioInFeed,
    this.autoWatchOnReply,
    this.keyboardBindings,
    this.keyboardPreset,
    this.mutedUsersByRoom,
    this.iconTheme,
    this.followedTopics,
    this.mutedTopics,
    this.imagePixelSize,
    this.timeDisplayFormat,
    this.useLegacyMenuOrder,
    this.defaultPublicPost,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        notifications: json['notifications'] != null
            ? NotificationSettings.fromJson(
                json['notifications'] as Map<String, dynamic>)
            : null,
        filterNSFW: json['filterNSFW'] as bool?,
        showFollowerCount: json['showFollowerCount'] as bool?,
        hideImagesInFeed: json['hideImagesInFeed'] as bool?,
        hideAudioInFeed: json['hideAudioInFeed'] as bool?,
        autoWatchOnReply: json['autoWatchOnReply'] as bool?,
        keyboardBindings: json['keyboardBindings'],
        keyboardPreset: json['keyboardPreset'] as String?,
        mutedUsersByRoom: json['mutedUsersByRoom'] as Map<String, dynamic>?,
        iconTheme: json['iconTheme'] as String?,
        followedTopics: json['followedTopics'] != null
            ? (json['followedTopics'] as List).cast<String>()
            : null,
        mutedTopics: json['mutedTopics'] != null
            ? (json['mutedTopics'] as List).cast<String>()
            : null,
        imagePixelSize: json['imagePixelSize'] as int?,
        timeDisplayFormat: json['timeDisplayFormat'] as String?,
        useLegacyMenuOrder: json['useLegacyMenuOrder'] as bool?,
        defaultPublicPost: json['defaultPublicPost'] as bool?,
      );
}
