import '../models.dart';
import 'resource.dart';

class SettingsResource {
  final RequestFn _request;

  SettingsResource(this._request);

  Future<Settings> get() async {
    final response =
        await _request('GET', '/v1/settings') as Map<String, dynamic>;
    return Settings.fromJson(responseDataObject(response));
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
      'filterNSFW': ?filterNSFW,
      'showFollowerCount': ?showFollowerCount,
      'hideImagesInFeed': ?hideImagesInFeed,
      'hideAudioInFeed': ?hideAudioInFeed,
      'autoWatchOnReply': ?autoWatchOnReply,
      'keyboardBindings': ?keyboardBindings,
      'keyboardPreset': ?keyboardPreset,
      'mutedUsersByRoom': ?mutedUsersByRoom,
      'iconTheme': ?iconTheme,
      'followedTopics': ?followedTopics,
      'mutedTopics': ?mutedTopics,
      'imagePixelSize': ?imagePixelSize,
      'timeDisplayFormat': ?timeDisplayFormat,
      'useLegacyMenuOrder': ?useLegacyMenuOrder,
      'defaultPublicPost': ?defaultPublicPost,
    };
    await _request('PATCH', '/v1/settings', body: body);
  }
}
