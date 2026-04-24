abstract class AuthTokenProvider {
  Future<String?> getToken();
  Future<void> onUnauthorized(); // called on 401
}