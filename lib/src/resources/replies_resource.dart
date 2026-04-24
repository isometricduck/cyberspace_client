import '../models.dart';
import 'resource.dart';

class RepliesResource {
  final RequestFn _request;

  RepliesResource(this._request);

  Future<PagedResult<Reply>> list(
    String postId, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/posts/$postId/replies',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return parsePaged(raw, Reply.fromJson);
  }

  Future<Reply> get(String replyId) async {
    final data = await _request('GET', '/v1/replies/$replyId')
        as Map<String, dynamic>;
    return Reply.fromJson(data);
  }

  Future<String> create({
    required String postId,
    required String content,
    String? parentReplyId,
  }) async {
    final data = await _request(
      'POST',
      '/v1/replies',
      body: {
        'postId': postId,
        'content': content,
        if (parentReplyId != null) 'parentReplyId': parentReplyId,
      },
    ) as Map<String, dynamic>;
    return data['replyId'] as String;
  }

  Future<void> delete(String replyId) async {
    await _request('DELETE', '/v1/replies/$replyId');
  }
}
