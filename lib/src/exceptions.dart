/// Base type for failures raised by the Cyberspace client.
abstract class CyberspaceClientException implements Exception {
  /// Human-readable description of the failure.
  String get message;

  /// The underlying exception, when this wraps a lower-level failure.
  Object? get cause;
}

/// Thrown when the Cyberspace API returns an error response.
class CyberspaceApiException implements CyberspaceClientException {
  /// The error code returned by the API (e.g. `UNAUTHORIZED`, `NOT_FOUND`).
  final String code;

  /// Human-readable error message from the API.
  @override
  final String message;

  /// The HTTP status code of the response.
  final int statusCode;

  const CyberspaceApiException({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  @override
  Object? get cause => null;

  @override
  String toString() => 'CyberspaceApiException($statusCode $code): $message';
}

/// Thrown when a request cannot reach the API.
class CyberspaceNetworkException implements CyberspaceClientException {
  @override
  final String message;

  @override
  final Object cause;

  const CyberspaceNetworkException({
    required this.message,
    required this.cause,
  });

  @override
  String toString() => 'CyberspaceNetworkException: $message';
}

/// Thrown when the API returns a response the client cannot understand.
class CyberspaceResponseException implements CyberspaceClientException {
  @override
  final String message;

  /// The HTTP status code of the response, if a response was received.
  final int? statusCode;

  @override
  final Object? cause;

  const CyberspaceResponseException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  @override
  String toString() {
    final status = statusCode == null ? '' : '($statusCode) ';
    return 'CyberspaceResponseException$status: $message';
  }
}
