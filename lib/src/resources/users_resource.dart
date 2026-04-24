import '../models.dart';
import 'resource.dart';

const _omit = Object();

class UsersResource {
  final RequestFn _request;

  UsersResource(this._request);

  Future<UserProfile> getMe() async {
    final data =
        await _request('GET', '/v1/users/me') as Map<String, dynamic>;
    return UserProfile.fromJson(data['data']);
  }

  Future<UserProfile> get(String username) async {
    final data = await _request('GET', '/v1/users/$username')
        as Map<String, dynamic>;
    return UserProfile.fromJson(data['data']);
  }

  Future<PagedResult<Post>> listPosts(
    String username, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/users/$username/posts',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return parsePaged(raw, Post.fromJson);
  }

  Future<PagedResult<Reply>> listReplies(
    String username, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/users/$username/replies',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return parsePaged(raw, Reply.fromJson);
  }

  /// Pass `null` for a field to explicitly clear it.
  Future<void> updateProfile({
    Object? bio = _omit,
    Object? pinnedPostId = _omit,
    Object? displayName = _omit,
    Object? websiteUrl = _omit,
    Object? websiteName = _omit,
    Object? websiteImageUrl = _omit,
    Object? locationLatitude = _omit,
    Object? locationLongitude = _omit,
    Object? locationName = _omit,
  }) async {
    final body = <String, dynamic>{};
    if (!identical(bio, _omit)) body['bio'] = bio;
    if (!identical(pinnedPostId, _omit)) body['pinnedPostId'] = pinnedPostId;
    if (!identical(displayName, _omit)) body['displayName'] = displayName;
    if (!identical(websiteUrl, _omit)) body['websiteUrl'] = websiteUrl;
    if (!identical(websiteName, _omit)) body['websiteName'] = websiteName;
    if (!identical(websiteImageUrl, _omit)) {
      body['websiteImageUrl'] = websiteImageUrl;
    }
    if (!identical(locationLatitude, _omit)) {
      body['locationLatitude'] = locationLatitude;
    }
    if (!identical(locationLongitude, _omit)) {
      body['locationLongitude'] = locationLongitude;
    }
    if (!identical(locationName, _omit)) body['locationName'] = locationName;

    await _request('PATCH', '/v1/users/me', body: body);
  }
}
