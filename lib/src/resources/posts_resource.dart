import '../models.dart';
import 'resource.dart';

class PostsResource {
  final RequestFn _request;

  PostsResource(this._request);

  Future<PagedResult<Post>> list({int limit = 20, String? cursor}) async {
    final raw =
        await _request(
              'GET',
              '/v1/posts',
              queryParams: {'limit': limit.toString(), 'cursor': cursor},
            )
            as Map<String, dynamic>;
    return parsePaged(raw, Post.fromJson);
  }

  Future<Post> get(String postId) async {
    final response =
        await _request('GET', '/v1/posts/$postId') as Map<String, dynamic>;
    return Post.fromJson(responseDataObject(response));
  }

  Future<String> create({
    required String content,
    List<String>? topics,
    bool isPublic = false,
    bool isNSFW = false,
  }) async {
    final response =
        await _request(
              'POST',
              '/v1/posts',
              body: {
                'content': content,
                'topics': ?topics,
                'isPublic': isPublic,
                'isNSFW': isNSFW,
              },
            )
            as Map<String, dynamic>;
    final data = responseDataObject(response);
    return data['postId'] as String;
  }

  Future<void> delete(String postId) async {
    await _request('DELETE', '/v1/posts/$postId');
  }
}
