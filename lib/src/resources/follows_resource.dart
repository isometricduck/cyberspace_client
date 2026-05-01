import '../models.dart';
import 'resource.dart';

class FollowsResource {
  final RequestFn _request;

  FollowsResource(this._request);

  Future<PagedResult<Follow>> listFollowers({
    String? userId,
    int limit = 20,
    String? cursor,
  }) async {
    final raw =
        await _request(
              'GET',
              '/v1/follows',
              queryParams: {
                'type': 'followers',
                'userId': ?userId,
                'limit': limit.toString(),
                'cursor': cursor,
              },
            )
            as Map<String, dynamic>;
    return parsePaged(raw, Follow.fromJson);
  }

  Future<PagedResult<Follow>> listFollowing({
    String? userId,
    int limit = 20,
    String? cursor,
  }) async {
    final raw =
        await _request(
              'GET',
              '/v1/follows',
              queryParams: {
                'type': 'following',
                'userId': ?userId,
                'limit': limit.toString(),
                'cursor': cursor,
              },
            )
            as Map<String, dynamic>;
    return parsePaged(raw, Follow.fromJson);
  }

  Future<String> follow(String followedId) async {
    final response =
        await _request('POST', '/v1/follows', body: {'followedId': followedId})
            as Map<String, dynamic>;
    final data = responseDataObject(response);
    return data['followId'] as String;
  }

  Future<void> unfollow(String followId) async {
    await _request('DELETE', '/v1/follows/$followId');
  }
}
