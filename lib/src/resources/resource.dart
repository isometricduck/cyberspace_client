import '../models.dart';

typedef RequestFn = Future<dynamic> Function(
  String method,
  String path, {
  Map<String, dynamic>? body,
  Map<String, String?>? queryParams,
  bool requiresAuth,
});

PagedResult<T> parsePaged<T>(
  Map<String, dynamic> raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  final items = (raw['data'] as List)
      .cast<Map<String, dynamic>>()
      .map(fromJson)
      .toList();
  return PagedResult(data: items, cursor: raw['cursor'] as String?);
}
