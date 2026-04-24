import '../models.dart';
import 'resource.dart';

class SettingsResource {
  final RequestFn _request;

  SettingsResource(this._request);

  Future<Settings> get() async {
    final data =
        await _request('GET', '/v1/settings') as Map<String, dynamic>;
    return Settings.fromJson(data);
  }

  Future<void> update({
    NotificationSettings? notifications,
    bool? filterNSFW,
    bool? showFollowerCount,
    bool? hideImagesInFeed,
    bool? hideAudioInFeed,
    bool? autoWatchOnReply,
    dynamic keyboardBindings,
    String? keyboardPreset,
    Map<String, dynamic>? mutedUsersByRoom,
    String? iconTheme,
    List<String>? followedTopics,
    List<String>? mutedTopics,
    int? imagePixelSize,
    String? timeDisplayFormat,
    bool? useLegacyMenuOrder,
    bool? defaultPublicPost,
  }) async {
    final body = <String, dynamic>{
      if (notifications != null) 'notifications': notifications.toJson(),
      if (filterNSFW != null) 'filterNSFW': filterNSFW,
      if (showFollowerCount != null) 'showFollowerCount': showFollowerCount,
      if (hideImagesInFeed != null) 'hideImagesInFeed': hideImagesInFeed,
      if (hideAudioInFeed != null) 'hideAudioInFeed': hideAudioInFeed,
      if (autoWatchOnReply != null) 'autoWatchOnReply': autoWatchOnReply,
      if (keyboardBindings != null) 'keyboardBindings': keyboardBindings,
      if (keyboardPreset != null) 'keyboardPreset': keyboardPreset,
      if (mutedUsersByRoom != null) 'mutedUsersByRoom': mutedUsersByRoom,
      if (iconTheme != null) 'iconTheme': iconTheme,
      if (followedTopics != null) 'followedTopics': followedTopics,
      if (mutedTopics != null) 'mutedTopics': mutedTopics,
      if (imagePixelSize != null) 'imagePixelSize': imagePixelSize,
      if (timeDisplayFormat != null) 'timeDisplayFormat': timeDisplayFormat,
      if (useLegacyMenuOrder != null) 'useLegacyMenuOrder': useLegacyMenuOrder,
      if (defaultPublicPost != null) 'defaultPublicPost': defaultPublicPost,
    };
    await _request('PATCH', '/v1/settings', body: body);
  }
}
