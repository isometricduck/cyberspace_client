import 'dart:io';

import 'package:cyberspace_client/cyberspace_client.dart';
import 'package:flutter_test/flutter_test.dart';

const _defaultMockApiBaseUrl = 'http://localhost:6000';

class _MemoryAuthTokenProvider implements AuthTokenProvider {
  String? idToken;
  String? refreshToken;
  bool unauthorized = false;

  void set(AuthTokens tokens) {
    idToken = tokens.idToken;
    refreshToken = tokens.refreshToken;
    unauthorized = false;
  }

  @override
  Future<String?> getToken() async => idToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> onTokensRefreshed(RefreshedTokens tokens) async {
    idToken = tokens.idToken;
  }

  @override
  Future<void> onUnauthorized() async {
    unauthorized = true;
    idToken = null;
    refreshToken = null;
  }
}

void main() {
  _EndpointFixture? fixture;

  setUpAll(() async {
    fixture = await _EndpointFixture.create();
  });

  tearDownAll(() {
    fixture?.dispose();
  });

  group('AuthResource', () {
    test('register returns auth tokens', () {
      expect(fixture!.registeredTokens.idToken, isNotEmpty);
      expect(fixture!.registeredTokens.refreshToken, isNotEmpty);
      expect(fixture!.registeredTokens.rtdbToken, isNotEmpty);
    });

    test('login returns auth tokens', () async {
      final tokens = await fixture!.client.auth.login(
        email: fixture!.primaryEmail,
        password: fixture!.password,
      );

      expect(tokens.idToken, isNotEmpty);
      expect(tokens.refreshToken, isNotEmpty);
      expect(tokens.rtdbToken, isNotEmpty);
      fixture!.provider.set(tokens);
    });

    test('refreshToken returns refreshed tokens', () async {
      final tokens = await fixture!.client.auth.refreshToken(
        fixture!.registeredTokens.refreshToken,
      );

      expect(tokens.idToken, isNotEmpty);
      expect(tokens.rtdbToken, isNotEmpty);
    });

    test('resendVerification completes', () async {
      await fixture!.client.auth.resendVerification(
        fixture!.registeredTokens.idToken,
      );
    });

    test('checkUsername returns availability', () async {
      final result = await fixture!.client.auth.checkUsername(
        'available_${fixture!.unique}',
      );

      expect(result.available, isA<bool>());
    });
  });

  group('PostsResource', () {
    test('list returns paged posts', () async {
      final posts = await fixture!.client.posts.list(limit: 2);

      expect(posts.data, isA<List<Post>>());
    });

    test('create returns a post id', () async {
      final postId = await fixture!.createPost('post created by test');

      expect(postId, isNotEmpty);
      await fixture!.client.posts.delete(postId);
    });

    test('get returns a post', () async {
      final post = await fixture!.client.posts.get(fixture!.postId);

      expect(post.postId, fixture!.postId);
      expect(post.content, isNotEmpty);
    });

    test('delete completes', () async {
      final postId = await fixture!.createPost('post to delete');

      await fixture!.client.posts.delete(postId);
    });
  });

  group('RepliesResource', () {
    test('list returns paged replies for a post', () async {
      final replies = await fixture!.client.replies.list(
        fixture!.postId,
        limit: 2,
      );

      expect(replies.data, isA<List<Reply>>());
    });

    test('create returns a reply id', () async {
      final replyId = await fixture!.createReply('reply created by test');

      expect(replyId, isNotEmpty);
      await fixture!.client.replies.delete(replyId);
    });

    test('get returns a reply', () async {
      final reply = await fixture!.client.replies.get(fixture!.replyId);

      expect(reply.replyId, fixture!.replyId);
      expect(reply.postId, fixture!.postId);
    });

    test('delete completes', () async {
      final replyId = await fixture!.createReply('reply to delete');

      await fixture!.client.replies.delete(replyId);
    });
  });

  group('UsersResource', () {
    test('getMe returns the authenticated user profile', () async {
      final profile = await fixture!.client.users.getMe();

      expect(profile.username, fixture!.primaryUsername);
    });

    test('get returns a user profile', () async {
      final profile = await fixture!.client.users.get(
        fixture!.secondaryUsername,
      );

      expect(profile.username, fixture!.secondaryUsername);
    });

    test('listPosts returns a user post page', () async {
      final posts = await fixture!.client.users.listPosts(
        fixture!.primaryUsername,
        limit: 2,
      );

      expect(posts.data, isA<List<Post>>());
    });

    test('listReplies returns a user reply page', () async {
      final replies = await fixture!.client.users.listReplies(
        fixture!.primaryUsername,
        limit: 2,
      );

      expect(replies.data, isA<List<Reply>>());
    });

    test('updateProfile completes', () async {
      await fixture!.client.users.updateProfile(
        bio: 'bio ${fixture!.unique}',
        displayName: 'Display ${fixture!.unique}',
        websiteUrl: 'https://example.com/${fixture!.unique}',
        websiteName: 'Example',
        locationLatitude: 51.5074,
        locationLongitude: -0.1278,
        locationName: 'London, UK',
      );
    });
  });

  group('BookmarksResource', () {
    test('list returns paged bookmarks', () async {
      final bookmarks = await fixture!.client.bookmarks.list(limit: 2);

      expect(bookmarks.data, isA<List<Bookmark>>());
    });

    test('bookmarkPost returns a bookmark id', () async {
      final bookmarkId = await fixture!.client.bookmarks.bookmarkPost(
        fixture!.postId,
      );
      fixture!.bookmarkIds.add(bookmarkId);

      expect(bookmarkId, isNotEmpty);
    });

    test('bookmarkReply returns a bookmark id', () async {
      final bookmarkId = await fixture!.client.bookmarks.bookmarkReply(
        fixture!.replyId,
      );
      fixture!.bookmarkIds.add(bookmarkId);

      expect(bookmarkId, isNotEmpty);
    });

    test('remove completes', () async {
      final bookmarkId = fixture!.bookmarkIds.isNotEmpty
          ? fixture!.bookmarkIds.removeLast()
          : await fixture!.client.bookmarks.bookmarkPost(fixture!.postId);

      await fixture!.client.bookmarks.remove(bookmarkId);
    });
  });

  group('FollowsResource', () {
    test('listFollowers returns paged follows', () async {
      final follows = await fixture!.client.follows.listFollowers(limit: 2);

      expect(follows.data, isA<List<Follow>>());
    });

    test('listFollowing returns paged follows', () async {
      final follows = await fixture!.client.follows.listFollowing(limit: 2);

      expect(follows.data, isA<List<Follow>>());
    });

    test('follow returns a follow id', () async {
      final followId = await fixture!.client.follows.follow(
        fixture!.secondaryUserId,
      );
      fixture!.followIds.add(followId);

      expect(followId, isNotEmpty);
    });

    test('unfollow completes', () async {
      final followId = fixture!.followIds.isNotEmpty
          ? fixture!.followIds.removeLast()
          : await fixture!.client.follows.follow(fixture!.secondaryUserId);

      await fixture!.client.follows.unfollow(followId);
    });
  });

  group('NotificationsResource', () {
    test('list returns paged notifications', () async {
      final notifications = await fixture!.client.notifications.list(limit: 2);

      expect(notifications.data, isA<List>());
    });

    test('markRead completes', () async {
      await fixture!.client.notifications.markRead(
        'notification-${fixture!.unique}',
      );
    });

    test('markAllRead returns an update count', () async {
      final updated = await fixture!.client.notifications.markAllRead();

      expect(updated, isNonNegative);
    });
  });

  group('NotesResource', () {
    test('list returns paged notes', () async {
      final notes = await fixture!.client.notes.list(limit: 2);

      expect(notes.data, isA<List<Note>>());
    });

    test('create returns a note id', () async {
      final noteId = await fixture!.createNote('note created by test');

      expect(noteId, isNotEmpty);
      await fixture!.client.notes.delete(noteId);
    });

    test('get returns a note', () async {
      final note = await fixture!.client.notes.get(fixture!.noteId);

      expect(note.noteId, fixture!.noteId);
      expect(note.content, isNotEmpty);
    });

    test('listRevisions returns paged notes', () async {
      final revisions = await fixture!.client.notes.listRevisions(
        fixture!.noteId,
        limit: 2,
      );

      expect(revisions.data, isA<List<Note>>());
    });

    test('update completes', () async {
      await fixture!.client.notes.update(
        fixture!.noteId,
        content: 'updated note ${fixture!.unique}',
        topics: ['testing'],
      );
    });

    test('delete completes', () async {
      final noteId = await fixture!.createNote('note to delete');

      await fixture!.client.notes.delete(noteId);
    });
  });

  group('TopicsResource', () {
    test('list returns topics', () async {
      final topics = await fixture!.client.topics.list();

      expect(topics, isA<List<Topic>>());
    });

    test('listPosts returns paged topic posts', () async {
      final posts = await fixture!.client.topics.listPosts('testing', limit: 2);

      expect(posts.data, isA<List<Post>>());
    });
  });

  group('SettingsResource', () {
    test('get returns settings', () async {
      final settings = await fixture!.client.settings.get();

      expect(settings, isA<Settings>());
    });

    test('update completes', () async {
      await fixture!.client.settings.update(
        notifications: const NotificationSettings(
          bookmark: true,
          reply: true,
          poke: false,
        ),
        filterNSFW: true,
        autoWatchOnReply: true,
      );
    });
  });
}

class _EndpointFixture {
  _EndpointFixture._({
    required this.client,
    required this.provider,
    required this.unique,
    required this.primaryUsername,
    required this.primaryEmail,
    required this.secondaryUsername,
    required this.password,
    required this.registeredTokens,
    required this.secondaryUserId,
    required this.postId,
    required this.replyId,
    required this.noteId,
  });

  final CyberspaceClient client;
  final _MemoryAuthTokenProvider provider;
  final String unique;
  final String primaryUsername;
  final String primaryEmail;
  final String secondaryUsername;
  final String password;
  final AuthTokens registeredTokens;
  final String secondaryUserId;
  final String postId;
  final String replyId;
  final String noteId;
  final List<String> bookmarkIds = [];
  final List<String> followIds = [];

  static Future<_EndpointFixture> create() async {
    final baseUrl =
        Platform.environment['CYBERSPACE_API_BASE_URL'] ??
        _defaultMockApiBaseUrl;
    final unique = DateTime.now().microsecondsSinceEpoch.toString();
    final provider = _MemoryAuthTokenProvider();
    final client = CyberspaceClient(
      authTokenProvider: provider,
      baseUrl: baseUrl,
    );
    const primaryUsername = 'case';
    final secondaryUsername = 'friend_$unique';
    final password = 'correct horse battery staple';
    final primaryEmail = '$primaryUsername@example.com';

    final registeredTokens = await client.auth.register(
      email: primaryEmail,
      password: password,
      username: primaryUsername,
    );
    provider.set(registeredTokens);

    await client.auth.register(
      email: '$secondaryUsername@example.com',
      password: password,
      username: secondaryUsername,
    );

    const secondaryUserId = 'user_mock_001';
    const postId = 'post_001';
    const replyId = 'reply_001';
    const noteId = 'note_001';

    return _EndpointFixture._(
      client: client,
      provider: provider,
      unique: unique,
      primaryUsername: primaryUsername,
      primaryEmail: primaryEmail,
      secondaryUsername: secondaryUsername,
      password: password,
      registeredTokens: registeredTokens,
      secondaryUserId: secondaryUserId,
      postId: postId,
      replyId: replyId,
      noteId: noteId,
    );
  }

  Future<String> createPost(String content) => client.posts.create(
    content: '$content $unique',
    topics: ['testing'],
    isPublic: true,
  );

  Future<String> createReply(String content) =>
      client.replies.create(postId: postId, content: '$content $unique');

  Future<String> createNote(String content) =>
      client.notes.create(content: '$content $unique', topics: ['testing']);

  void dispose() {
    client.dispose();
  }
}
