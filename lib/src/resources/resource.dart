import 'package:flutter/widgets.dart';

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
  debugPrint('Parsing paged result');
  final items = (raw['data'] as List)
      .cast<Map<String, dynamic>>()
      .map(fromJson)
      .toList();
  debugPrint('Items: $items');
  final result = PagedResult(data: items, cursor: raw['cursor'] as String?);
  debugPrint('Parsed paged result: $result');
  return result;
}
