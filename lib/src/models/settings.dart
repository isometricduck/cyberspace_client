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
