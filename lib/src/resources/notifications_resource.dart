import '../models.dart';
import 'resource.dart';

class NotificationsResource {
  final RequestFn _request;

  NotificationsResource(this._request);

  Future<PagedResult<Notification>> list({
    int limit = 20,
    String? cursor,
  }) async {
    final raw =
        await _request(
              'GET',
              '/v1/notifications',
              queryParams: {'limit': limit.toString(), 'cursor': cursor},
            )
            as Map<String, dynamic>;
    return parsePaged(raw, Notification.fromJson);
  }

  Future<void> markRead(String notificationId) async {
    await _request('PATCH', '/v1/notifications/$notificationId');
  }

  Future<int> markAllRead() async {
    final response =
        await _request('POST', '/v1/notifications/read-all')
            as Map<String, dynamic>;
    final data = responseDataObject(response);
    return data['updated'] as int;
  }
}
