import '../models.dart';
import '../exceptions.dart';

typedef RequestFn =
    Future<dynamic> Function(
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
  final page = responseData(raw);
  final List<dynamic> rawItems;
  final String? cursor;

  if (page is Map<String, dynamic>) {
    rawItems = page['data'] as List;
    cursor = page['cursor'] as String?;
  } else if (page is List) {
    rawItems = page;
    cursor = raw['cursor'] as String?;
  } else {
    throw const CyberspaceResponseException(
      message: 'Expected response data to contain a page object.',
    );
  }

  final items = rawItems.cast<Map<String, dynamic>>().map(fromJson).toList();
  return PagedResult(data: items, cursor: cursor);
}

dynamic responseData(Map<String, dynamic> raw) {
  if (!raw.containsKey('data')) {
    throw const CyberspaceResponseException(
      message: 'Expected response to contain a data envelope.',
    );
  }

  return raw['data'];
}

Map<String, dynamic> responseDataObject(Map<String, dynamic> raw) {
  final data = responseData(raw);
  if (data is Map<String, dynamic>) {
    return data;
  }

  throw const CyberspaceResponseException(
    message: 'Expected response data to be a JSON object.',
  );
}

List<Map<String, dynamic>> responseDataList(Map<String, dynamic> raw) {
  final data = responseData(raw);
  if (data is List) {
    return data.cast<Map<String, dynamic>>();
  }

  throw const CyberspaceResponseException(
    message: 'Expected response data to be a JSON array.',
  );
}
