import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'models.dart';

const _defaultBaseUrl = 'https://api.cyberspace.online';

/// Client for the Cyberspace REST API v0.3.4.
///
/// Obtain tokens by calling [login] or [register]; subsequent calls will
/// automatically include the `Authorization: Bearer` header.
///
/// ```dart
/// final client = CyberspaceClient();
/// await client.login(email: 'you@example.com', password: 's3cr3t');
/// final feed = await client.listPosts();
/// ```
class CyberspaceClient {
  final String baseUrl;
  final http.Client _http;

  String? _idToken;
  String? _refreshToken;
  String? _rtdbToken;

  /// The currently stored ID token, or `null` if not authenticated.
  String? get idToken => _idToken;

  /// The currently stored refresh token, or `null` if not authenticated.
  String? getRefreshToken() => _refreshToken;

  /// The Firebase Realtime Database token for chat/DMs.
  String? get rtdbToken => _rtdbToken;

  CyberspaceClient({
    this.baseUrl = _defaultBaseUrl,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  /// Manually set the auth token (e.g. after restoring a session).
  void setToken(String idToken, {String? refreshToken, String? rtdbToken}) {
    _idToken = idToken;
    _refreshToken = refreshToken;
    _rtdbToken = rtdbToken;
  }

  /// Clears all stored tokens.
  void clearToken() {
    _idToken = null;
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
      if (_idToken == null) {
        throw StateError('Not authenticated — call login() or setToken() first');
      }
      headers['Authorization'] = 'Bearer $_idToken';
    }

    final encodedBody = body != null ? jsonEncode(body) : null;

    late http.Response response;
    switch (method) {
      case 'GET':
        response = await _http.get(uri, headers: headers);
      case 'POST':
        response =
            await _http.post(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        response =
            await _http.patch(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        response = await _http.delete(uri, headers: headers);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final error = decoded['error'] as Map<String, dynamic>;
      throw CyberspaceApiException(
        code: error['code'] as String,
        message: error['message'] as String,
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  PagedResult<T> _parsePaged<T>(
    Map<String, dynamic> raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    print("Raw is $raw");
    final items = (raw['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
    return PagedResult(data: items, cursor: raw['cursor'] as String?);
  }

  // ─── Auth ───────────────────────────────────────────────────────────────────

  /// Authenticates with email/password. Stores the returned tokens.
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/v1/auth/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    ) as Map<String, dynamic>;

    final tokens = AuthTokens.fromJson(data['data']);
    _idToken = tokens.idToken;
    _refreshToken = tokens.refreshToken;
    _rtdbToken = tokens.rtdbToken;
    return tokens;
  }

  /// Creates a new account. Stores the returned tokens.
  Future<AuthTokens> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final data = await _request(
      'POST',
      '/v1/auth/register',
      body: {'email': email, 'password': password, 'username': username},
      requiresAuth: false,
    ) as Map<String, dynamic>;

    final tokens = AuthTokens.fromJson(data);
    _idToken = tokens.idToken;
    _refreshToken = tokens.refreshToken;
    _rtdbToken = tokens.rtdbToken;
    return tokens;
  }

  /// Exchanges a refresh token for a new ID token and RTDB token.
  /// Automatically updates the stored tokens.
  Future<RefreshedTokens> refreshToken(String refreshToken) async {
    final data = await _request(
      'POST',
      '/v1/auth/refresh',
      body: {'refreshToken': refreshToken},
      requiresAuth: false,
    ) as Map<String, dynamic>;

    final tokens = RefreshedTokens.fromJson(data);
    _idToken = tokens.idToken;
    _rtdbToken = tokens.rtdbToken;
    return tokens;
  }

  /// Resends the account verification email.
  Future<void> resendVerification(String idToken) async {
    await _request(
      'POST',
      '/v1/auth/resend-verification',
      body: {'idToken': idToken},
      requiresAuth: false,
    );
  }

  /// Returns whether [username] is available.
  Future<({bool available, String? reason})> checkUsername(
      String username) async {
    final data = await _request(
      'POST',
      '/v1/auth/check-username',
      body: {'username': username},
      requiresAuth: false,
    ) as Map<String, dynamic>;

    return (
      available: data['available'] as bool,
      reason: data['reason'] as String?,
    );
  }

  // ─── Posts (Entries) ────────────────────────────────────────────────────────

  /// Lists the global entry feed.
  Future<PagedResult<Post>> listPosts({int limit = 20, String? cursor}) async {
    final raw = await _request('GET', '/v1/posts', queryParams: {
      'limit': limit.toString(),
      'cursor': cursor,
    }) as Map<String, dynamic>;
    return _parsePaged(raw, Post.fromJson);
  }

  /// Gets a single entry by ID.
  Future<Post> getPost(String postId) async {
    final data =
        await _request('GET', '/v1/posts/$postId') as Map<String, dynamic>;
    return Post.fromJson(data);
  }

  /// Creates a new entry. Returns the new post's ID.
  Future<String> createPost({
    required String content,
    List<String>? topics,
    bool isPublic = false,
    bool isNSFW = false,
  }) async {
    final data = await _request(
      'POST',
      '/v1/posts',
      body: {
        'content': content,
        if (topics != null) 'topics': topics,
        'isPublic': isPublic,
        'isNSFW': isNSFW,
      },
    ) as Map<String, dynamic>;
    return data['postId'] as String;
  }

  /// Deletes an entry. Only the author or an admin can do this.
  Future<void> deletePost(String postId) async {
    await _request('DELETE', '/v1/posts/$postId');
  }

  // ─── Replies ─────────────────────────────────────────────────────────────────

  /// Lists replies for [postId], oldest first.
  Future<PagedResult<Reply>> listReplies(
    String postId, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/posts/$postId/replies',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Reply.fromJson);
  }

  /// Gets a single reply by ID.
  Future<Reply> getReply(String replyId) async {
    final data = await _request('GET', '/v1/replies/$replyId')
        as Map<String, dynamic>;
    return Reply.fromJson(data);
  }

  /// Creates a reply. Returns the new reply's ID.
  Future<String> createReply({
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

  /// Deletes a reply. Only the author or an admin can do this.
  Future<void> deleteReply(String replyId) async {
    await _request('DELETE', '/v1/replies/$replyId');
  }

  // ─── Users ───────────────────────────────────────────────────────────────────

  /// Returns the authenticated user's own profile.
  Future<UserProfile> getMe() async {
    final data =
        await _request('GET', '/v1/users/me') as Map<String, dynamic>;
    return UserProfile.fromJson(data['data']);
  }

  /// Returns the public profile of [username].
  Future<UserProfile> getUser(String username) async {
    final data = await _request('GET', '/v1/users/$username')
        as Map<String, dynamic>;
    return UserProfile.fromJson(data['data']);
  }

  /// Lists entries posted by [username].
  Future<PagedResult<Post>> listUserPosts(
    String username, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/users/$username/posts',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Post.fromJson);
  }

  /// Lists replies posted by [username].
  Future<PagedResult<Reply>> listUserReplies(
    String username, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/users/$username/replies',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Reply.fromJson);
  }

  /// Updates the authenticated user's own profile.
  /// Pass `null` for a field to explicitly clear it.
  Future<void> updateProfile({
    Object? bio = _omit,
    Object? pinnedPostId = _omit,
    Object? displayName = _omit,
    Object? websiteUrl = _omit,
    Object? websiteName = _omit,
    Object? websiteImageUrl = _omit,
    Object? locationLatitude = _omit,
    Object? locationLongitude = _omit,
    Object? locationName = _omit,
  }) async {
    final body = <String, dynamic>{};
    if (!identical(bio, _omit)) body['bio'] = bio;
    if (!identical(pinnedPostId, _omit)) body['pinnedPostId'] = pinnedPostId;
    if (!identical(displayName, _omit)) body['displayName'] = displayName;
    if (!identical(websiteUrl, _omit)) body['websiteUrl'] = websiteUrl;
    if (!identical(websiteName, _omit)) body['websiteName'] = websiteName;
    if (!identical(websiteImageUrl, _omit)) {
      body['websiteImageUrl'] = websiteImageUrl;
    }
    if (!identical(locationLatitude, _omit)) {
      body['locationLatitude'] = locationLatitude;
    }
    if (!identical(locationLongitude, _omit)) {
      body['locationLongitude'] = locationLongitude;
    }
    if (!identical(locationName, _omit)) body['locationName'] = locationName;

    await _request('PATCH', '/v1/users/me', body: body);
  }

  // ─── Bookmarks ───────────────────────────────────────────────────────────────

  /// Lists the authenticated user's bookmarks.
  Future<PagedResult<Bookmark>> listBookmarks({
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/bookmarks',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Bookmark.fromJson);
  }

  /// Bookmarks a post. Returns the new bookmark's ID.
  Future<String> bookmarkPost(String postId) async {
    final data = await _request(
      'POST',
      '/v1/bookmarks',
      body: {'postId': postId, 'type': 'post'},
    ) as Map<String, dynamic>;
    return data['bookmarkId'] as String;
  }

  /// Bookmarks a reply. Returns the new bookmark's ID.
  Future<String> bookmarkReply(String replyId) async {
    final data = await _request(
      'POST',
      '/v1/bookmarks',
      body: {'replyId': replyId, 'type': 'reply'},
    ) as Map<String, dynamic>;
    return data['bookmarkId'] as String;
  }

  /// Removes a bookmark by its ID.
  Future<void> removeBookmark(String bookmarkId) async {
    await _request('DELETE', '/v1/bookmarks/$bookmarkId');
  }

  // ─── Follows ─────────────────────────────────────────────────────────────────

  /// Lists the authenticated user's followers.
  Future<PagedResult<Follow>> listFollowers({
    String? userId,
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/follows',
      queryParams: {
        'type': 'followers',
        if (userId != null) 'userId': userId,
        'limit': limit.toString(),
        'cursor': cursor,
      },
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Follow.fromJson);
  }

  /// Lists users the authenticated user is following.
  Future<PagedResult<Follow>> listFollowing({
    String? userId,
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/follows',
      queryParams: {
        'type': 'following',
        if (userId != null) 'userId': userId,
        'limit': limit.toString(),
        'cursor': cursor,
      },
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Follow.fromJson);
  }

  /// Follows a user by their user ID. Returns the follow document ID.
  Future<String> follow(String followedId) async {
    final data = await _request(
      'POST',
      '/v1/follows',
      body: {'followedId': followedId},
    ) as Map<String, dynamic>;
    return data['followId'] as String;
  }

  /// Unfollows by the follow document ID returned from [follow].
  Future<void> unfollow(String followId) async {
    await _request('DELETE', '/v1/follows/$followId');
  }

  // ─── Notifications ───────────────────────────────────────────────────────────

  /// Lists the authenticated user's notifications.
  Future<PagedResult<Notification>> listNotifications({
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/notifications',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Notification.fromJson);
  }

  /// Marks a single notification as read.
  Future<void> markNotificationRead(String notificationId) async {
    await _request('PATCH', '/v1/notifications/$notificationId');
  }

  /// Marks all unread notifications as read. Returns the count updated.
  Future<int> markAllNotificationsRead() async {
    final data = await _request('POST', '/v1/notifications/read-all')
        as Map<String, dynamic>;
    return data['updated'] as int;
  }

  // ─── Notes ───────────────────────────────────────────────────────────────────

  /// Lists the authenticated user's private notes (latest revision each).
  Future<PagedResult<Note>> listNotes({int limit = 20, String? cursor}) async {
    final raw = await _request(
      'GET',
      '/v1/notes',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Note.fromJson);
  }

  /// Gets a note. Pass [revision] to retrieve a specific revision number.
  Future<Note> getNote(String noteId, {int? revision}) async {
    final data = await _request(
      'GET',
      '/v1/notes/$noteId',
      queryParams: {if (revision != null) 'revision': revision.toString()},
    ) as Map<String, dynamic>;
    return Note.fromJson(data);
  }

  /// Lists all revisions for a note, newest first.
  Future<PagedResult<Note>> listNoteRevisions(
    String noteId, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/notes/$noteId/revisions',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Note.fromJson);
  }

  /// Creates a new private note. Returns the new note's ID.
  Future<String> createNote({
    required String content,
    List<String>? topics,
  }) async {
    final data = await _request(
      'POST',
      '/v1/notes',
      body: {
        'content': content,
        if (topics != null) 'topics': topics,
      },
    ) as Map<String, dynamic>;
    return data['noteId'] as String;
  }

  /// Updates a note, creating a new revision.
  Future<void> updateNote(
    String noteId, {
    required String content,
    List<String>? topics,
  }) async {
    await _request(
      'PATCH',
      '/v1/notes/$noteId',
      body: {
        'content': content,
        if (topics != null) 'topics': topics,
      },
    );
  }

  /// Soft-deletes all revisions of a note.
  Future<void> deleteNote(String noteId) async {
    await _request('DELETE', '/v1/notes/$noteId');
  }

  // ─── Topics ──────────────────────────────────────────────────────────────────

  /// Lists all topics sorted by entry count, most popular first.
  Future<List<Topic>> listTopics() async {
    final data = await _request('GET', '/v1/topics') as List;
    return data
        .cast<Map<String, dynamic>>()
        .map(Topic.fromJson)
        .toList();
  }

  /// Lists entries tagged with [slug].
  Future<PagedResult<Post>> listTopicPosts(
    String slug, {
    int limit = 20,
    String? cursor,
  }) async {
    final raw = await _request(
      'GET',
      '/v1/topics/$slug/posts',
      queryParams: {'limit': limit.toString(), 'cursor': cursor},
    ) as Map<String, dynamic>;
    return _parsePaged(raw, Post.fromJson);
  }

  // ─── Settings ────────────────────────────────────────────────────────────────

  /// Returns the authenticated user's settings.
  Future<Settings> getSettings() async {
    final data =
        await _request('GET', '/v1/settings') as Map<String, dynamic>;
    return Settings.fromJson(data);
  }

  /// Updates user settings. Only the provided fields are changed.
  Future<void> updateSettings({
    NotificationSettings? notifications,
    bool? filterNSFW,
    bool? showFollowerCount,
    bool? hideImagesInFeed,
    bool? hideAudioInFeed,
    bool? autoWatchOnReply,
    dynamic keyboardBindings,
    String? keyboardPreset,
    Map<String, dynamic>? mutedUsersByRoom,
    String? iconTheme,
    List<String>? followedTopics,
    List<String>? mutedTopics,
    int? imagePixelSize,
    String? timeDisplayFormat,
    bool? useLegacyMenuOrder,
    bool? defaultPublicPost,
  }) async {
    final body = <String, dynamic>{
      if (notifications != null) 'notifications': notifications.toJson(),
      if (filterNSFW != null) 'filterNSFW': filterNSFW,
      if (showFollowerCount != null) 'showFollowerCount': showFollowerCount,
      if (hideImagesInFeed != null) 'hideImagesInFeed': hideImagesInFeed,
      if (hideAudioInFeed != null) 'hideAudioInFeed': hideAudioInFeed,
      if (autoWatchOnReply != null) 'autoWatchOnReply': autoWatchOnReply,
      if (keyboardBindings != null) 'keyboardBindings': keyboardBindings,
      if (keyboardPreset != null) 'keyboardPreset': keyboardPreset,
      if (mutedUsersByRoom != null) 'mutedUsersByRoom': mutedUsersByRoom,
      if (iconTheme != null) 'iconTheme': iconTheme,
      if (followedTopics != null) 'followedTopics': followedTopics,
      if (mutedTopics != null) 'mutedTopics': mutedTopics,
      if (imagePixelSize != null) 'imagePixelSize': imagePixelSize,
      if (timeDisplayFormat != null) 'timeDisplayFormat': timeDisplayFormat,
      if (useLegacyMenuOrder != null) 'useLegacyMenuOrder': useLegacyMenuOrder,
      if (defaultPublicPost != null) 'defaultPublicPost': defaultPublicPost,
    };
    await _request('PATCH', '/v1/settings', body: body);
  }

  /// Frees the underlying HTTP client. Call when done with the client.
  void dispose() => _http.close();
}

/// Sentinel used to distinguish "not passed" from explicit `null` in
/// [CyberspaceClient.updateProfile].
const _omit = Object();
