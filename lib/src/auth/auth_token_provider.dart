import '../models.dart';

abstract class AuthTokenProvider {
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<void> onTokensRefreshed(RefreshedTokens tokens);
  Future<void> onUnauthorized(); // called on 401
}
