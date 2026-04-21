import 'package:cyberspace_client/cyberspace_client.dart';

const _email = 'YOUR_EMAIL';
const _password = 'YOUR_PASSWORD';

Future<void> main() async {
  final client = CyberspaceClient();

  print('Logging in as $_email...');
  final tokens = await client.login(email: _email, password: _password);
  print('Logged in. idToken: ${tokens.idToken.substring(0, 20)}...');

  final me = await client.getMe();
  print('Hello, ${me.username}!');

  print('\nFetching feed...');
  final feed = await client.listPosts(limit: 10);
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
