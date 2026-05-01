import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth/auth_token_provider.dart';
import 'exceptions.dart';
import 'models.dart';
import 'resources/auth_resource.dart';
import 'resources/bookmarks_resource.dart';
import 'resources/follows_resource.dart';
import 'resources/notes_resource.dart';
import 'resources/notifications_resource.dart';
import 'resources/posts_resource.dart';
import 'resources/replies_resource.dart';
import 'resources/settings_resource.dart';
import 'resources/topics_resource.dart';
import 'resources/users_resource.dart';

const _defaultBaseUrl = 'https://api.cyberspace.online';

/// Client for the Cyberspace REST API v0.3.4.
///
/// Obtain tokens by calling [auth.login] or [auth.register]; subsequent calls
/// will automatically include the `Authorization: Bearer` header.
///
/// ```dart
/// final client = CyberspaceClient();
/// await client.auth.login(email: 'you@example.com', password: 's3cr3t');
/// final feed = await client.posts.list();
/// ```
class CyberspaceClient {
  final String baseUrl;
  final http.Client _http;

  String? _refreshToken;
  String? _rtdbToken;

  /// The currently stored refresh token, or `null` if not authenticated.
  String? getRefreshToken() => _refreshToken;

  /// The Firebase Realtime Database token for chat/DMs.
  String? get rtdbToken => _rtdbToken;

  final AuthTokenProvider authTokenProvider;

  late final AuthResource auth;
  late final PostsResource posts;
  late final RepliesResource replies;
  late final UsersResource users;
  late final BookmarksResource bookmarks;
  late final FollowsResource follows;
  late final NotificationsResource notifications;
  late final NotesResource notes;
  late final TopicsResource topics;
  late final SettingsResource settings;

  CyberspaceClient({
    required this.authTokenProvider,
    this.baseUrl = _defaultBaseUrl,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client() {
    auth = AuthResource(
      _request,
      onRefreshToken: (token) => _refreshToken = token,
      onRtdbToken: (token) => _rtdbToken = token,
    );
    posts = PostsResource(_request);
    replies = RepliesResource(_request);
    users = UsersResource(_request);
    bookmarks = BookmarksResource(_request);
    follows = FollowsResource(_request);
    notifications = NotificationsResource(_request);
    notes = NotesResource(_request);
    topics = TopicsResource(_request);
    settings = SettingsResource(_request);
  }

  /// Manually set the auth token (e.g. after restoring a session).
  void setToken(String idToken, {String? refreshToken, String? rtdbToken}) {
    _refreshToken = refreshToken;
    _rtdbToken = rtdbToken;
  }

  /// Clears all stored tokens.
  void clearToken() {
    _refreshToken = null;
    _rtdbToken = null;
  }

  // ─── Internal request helper ────────────────────────────────────────────────

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String?>? queryParams,
    bool requiresAuth = true,
  }) async {
    var uri = Uri.parse('$baseUrl$path');

    if (queryParams != null && queryParams.isNotEmpty) {
      final cleaned = <String, String>{};
      for (final entry in queryParams.entries) {
        if (entry.value != null) cleaned[entry.key] = entry.value!;
      }
      if (cleaned.isNotEmpty) {
        uri = uri.replace(queryParameters: cleaned);
      }
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await authTokenProvider.getToken();
      if (token == null) {
        throw StateError(
          'Not authenticated — call auth.login() or setToken() first',
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final encodedBody = body != null ? jsonEncode(body) : null;

    var response = await _sendRequest(method, uri, headers, encodedBody);

    if (requiresAuth && response.statusCode == 401) {
      final refreshToken = await authTokenProvider.getRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshed = await auth.refreshToken(refreshToken);
          await authTokenProvider.onTokensRefreshed(refreshed);

          final token = await authTokenProvider.getToken();
          if (token != null) {
            headers['Authorization'] = 'Bearer $token';
            response = await _sendRequest(method, uri, headers, encodedBody);
          }
        } on CyberspaceApiException catch (e) {
          if (e.statusCode != 401) rethrow;
          // Refresh token rejected — log out and surface the original 401.
          await authTokenProvider.onUnauthorized();
          final decoded = _decodeResponse(response);
          final error = _readError(response, decoded);
          throw CyberspaceApiException(
            code: error.code,
            message: error.message,
            statusCode: response.statusCode,
          );
        } catch (_) {
          // Network or response error from the refresh call — don't log out.
          rethrow;
        }
      } else {
        // No refresh token available.
        await authTokenProvider.onUnauthorized();
        final decoded = _decodeResponse(response);
        final error = _readError(response, decoded);
        throw CyberspaceApiException(
          code: error.code,
          message: error.message,
          statusCode: response.statusCode,
        );
      }
    }

    final decoded = _decodeResponse(response);

    if (response.statusCode >= 400) {
      if (requiresAuth && response.statusCode == 401) {
        await authTokenProvider.onUnauthorized();
      }

      final error = _readError(response, decoded);
      throw CyberspaceApiException(
        code: error.code,
        message: error.message,
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  Future<http.Response> _sendRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    String? encodedBody,
  ) async {
    try {
      switch (method) {
        case 'GET':
          return await _http.get(uri, headers: headers);
        case 'POST':
          return await _http.post(uri, headers: headers, body: encodedBody);
        case 'PATCH':
          return await _http.patch(uri, headers: headers, body: encodedBody);
        case 'DELETE':
          return await _http.delete(uri, headers: headers);
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
    } on CyberspaceClientException {
      rethrow;
    } on SocketException catch (error) {
      throw CyberspaceNetworkException(
        message: 'Could not connect to the Cyberspace API.',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw CyberspaceNetworkException(
        message: 'The Cyberspace API request failed.',
        cause: error,
      );
    } on IOException catch (error) {
      throw CyberspaceNetworkException(
        message: 'The Cyberspace API connection failed.',
        cause: error,
      );
    } on TimeoutException catch (error) {
      throw CyberspaceNetworkException(
        message: 'The Cyberspace API request timed out.',
        cause: error,
      );
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw CyberspaceResponseException(
        message: 'Expected the Cyberspace API response to be a JSON object.',
        statusCode: response.statusCode,
      );
    } on CyberspaceClientException {
      rethrow;
    } on FormatException catch (error) {
      throw CyberspaceResponseException(
        message: 'The Cyberspace API returned invalid JSON.',
        statusCode: response.statusCode,
        cause: error,
      );
    }
  }

  ({String code, String message}) _readError(
    http.Response response,
    Map<String, dynamic> decoded,
  ) {
    final error = decoded['error'];
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      final message = error['message'];
      if (code is String && message is String) {
        return (code: code, message: message);
      }
    }

    throw CyberspaceResponseException(
      message: 'The Cyberspace API returned a malformed error response.',
      statusCode: response.statusCode,
    );
  }

  // ─── Auth shortcuts ─────────────────────────────────────────────────────────

  Future<AuthTokens> login({required String email, required String password}) =>
      auth.login(email: email, password: password);

  Future<AuthTokens> register({
    required String email,
    required String password,
    required String username,
  }) => auth.register(email: email, password: password, username: username);

  Future<RefreshedTokens> refreshToken(String refreshToken) =>
      auth.refreshToken(refreshToken);

  Future<void> resendVerification(String idToken) =>
      auth.resendVerification(idToken);

  Future<({bool available, String? reason})> checkUsername(String username) =>
      auth.checkUsername(username);

  /// Frees the underlying HTTP client. Call when done with the client.
  void dispose() => _http.close();
}
