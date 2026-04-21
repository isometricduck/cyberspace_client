/// Thrown when the Cyberspace API returns an error response.
class CyberspaceApiException implements Exception {
  /// The error code returned by the API (e.g. `UNAUTHORIZED`, `NOT_FOUND`).
  final String code;

  /// Human-readable error message from the API.
  final String message;

  /// The HTTP status code of the response.
  final int statusCode;

  const CyberspaceApiException({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'CyberspaceApiException($statusCode $code): $message';
}
