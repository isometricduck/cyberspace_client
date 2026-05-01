import '../models.dart';
import 'resource.dart';

class NotesResource {
  final RequestFn _request;

  NotesResource(this._request);

  Future<PagedResult<Note>> list({int limit = 20, String? cursor}) async {
    final raw =
        await _request(
              'GET',
              '/v1/notes',
              queryParams: {'limit': limit.toString(), 'cursor': cursor},
            )
            as Map<String, dynamic>;
    return parsePaged(raw, Note.fromJson);
  }

  Future<Note> get(String noteId, {int? revision}) async {
    final response =
        await _request(
              'GET',
              '/v1/notes/$noteId',
              queryParams: {
                if (revision != null) 'revision': revision.toString(),
              },
            )
            as Map<String, dynamic>;
    return Note.fromJson(responseDataObject(response));
  }

  Future<PagedResult<Note>> listRevisions(
    String noteId, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw =
        await _request(
              'GET',
              '/v1/notes/$noteId/revisions',
              queryParams: {'limit': limit.toString(), 'cursor': cursor},
            )
            as Map<String, dynamic>;
    return parsePaged(raw, Note.fromJson);
  }

  Future<String> create({required String content, List<String>? topics}) async {
    final response =
        await _request(
              'POST',
              '/v1/notes',
              body: {'content': content, 'topics': ?topics},
            )
            as Map<String, dynamic>;
    final data = responseDataObject(response);
    return data['noteId'] as String;
  }

  Future<void> update(
    String noteId, {
    required String content,
    List<String>? topics,
  }) async {
    await _request(
      'PATCH',
      '/v1/notes/$noteId',
      body: {'content': content, 'topics': ?topics},
    );
  }

  Future<void> delete(String noteId) async {
    await _request('DELETE', '/v1/notes/$noteId');
  }
}
