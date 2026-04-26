import 'package:cyberspace_client/cyberspace_client.dart';

const _email = 'YOUR_EMAIL';
const _password = 'YOUR_PASSWORD';

class MyTokenProvider implements AuthTokenProvider {
  String? _idToken;
  String? _refreshToken;

  @override
  Future<String?> getToken() async => _idToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> onTokensRefreshed(RefreshedTokens tokens) async {
    _idToken = tokens.idToken;
  }

  @override
  Future<void> onUnauthorized() async {
    print('Unauthorized! Clearing token.');
    _idToken = null;
    _refreshToken = null;
  }

  void setTokens(AuthTokens tokens) {
    _idToken = tokens.idToken;
    _refreshToken = tokens.refreshToken;
  }
}

Future<void> main() async {
  final tokenProvider = MyTokenProvider();
  final client = CyberspaceClient(authTokenProvider: tokenProvider);

  print('Logging in as $_email...');
  final tokens = await client.login(email: _email, password: _password);
  tokenProvider.setTokens(tokens);
  print('Logged in. idToken: ${tokens.idToken.substring(0, 20)}...');

  final me = await client.users.getMe();
  print('Hello, ${me.username}!');

  print('\nFetching feed...');
  final feed = await client.posts.list(limit: 10);
  print('Got ${feed.data.length} posts:\n');

  for (final post in feed.data) {
    final topics = post.topics.isEmpty ? '' : '  [${post.topics.join(', ')}]';
    final preview = post.content.length > 80
        ? '${post.content.substring(0, 80)}...'
        : post.content;
    print('@${post.authorUsername}$topics');
    print(preview);
    print('  ${post.repliesCount} replies · ${post.createdAt.toLocal()}');
    print('');
  }

  if (feed.cursor != null) {
    print('More posts available (cursor: ${feed.cursor})');
  }

  client.dispose();
}
