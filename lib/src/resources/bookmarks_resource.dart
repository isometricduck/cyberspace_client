import '../models.dart';
import 'resource.dart';

class BookmarksResource {
  final RequestFn _request;

  BookmarksResource(this._request);

  Future<PagedResult<Bookmark>> list({int limit = 20, String? cursor}) async {
    final raw = await _request(
      'GET',
      '/v1/bookmarks',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return parsePaged(raw, Bookmark.fromJson);
  }

  Future<String> bookmarkPost(String postId) async {
    final response = await _request(
      'POST',
      '/v1/bookmarks',
      body: {'postId': postId, 'type': 'post'},
    ) as Map<String, dynamic>;
    final data = response['data'] as Map<String, dynamic>;
    return data['bookmarkId'] as String;
  }

  Future<String> bookmarkReply(String replyId) async {
    final response = await _request(
      'POST',
      '/v1/bookmarks',
      body: {'replyId': replyId, 'type': 'reply'},
    ) as Map<String, dynamic>;
    final data = response['data'] as Map<String, dynamic>;
    return data['bookmarkId'] as String;
  }

  Future<void> remove(String bookmarkId) async {
    await _request('DELETE', '/v1/bookmarks/$bookmarkId');
  }
}
