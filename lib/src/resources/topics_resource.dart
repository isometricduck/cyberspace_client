import '../models.dart';
import 'resource.dart';

class TopicsResource {
  final RequestFn _request;

  TopicsResource(this._request);

  Future<List<Topic>> list() async {
    final response =
        await _request('GET', '/v1/topics') as Map<String, dynamic>;
    return responseDataList(response).map(Topic.fromJson).toList();
  }

  Future<PagedResult<Post>> listPosts(
    String slug, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw =
        await _request(
              'GET',
              '/v1/topics/$slug/posts',
              queryParams: {'limit': limit.toString(), 'cursor': cursor},
            )
            as Map<String, dynamic>;
    return parsePaged(raw, Post.fromJson);
  }
}
