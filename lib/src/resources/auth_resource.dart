import '../models.dart';
import 'resource.dart';

class AuthResource {
  final RequestFn _request;
  final void Function(String refreshToken) _onRefreshToken;
  final void Function(String rtdbToken) _onRtdbToken;

  AuthResource(
    this._request, {
    required void Function(String) onRefreshToken,
    required void Function(String) onRtdbToken,
  }) : _onRefreshToken = onRefreshToken,
       _onRtdbToken = onRtdbToken;

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response =
        await _request(
              'POST',
              '/v1/auth/login',
              body: {'email': email, 'password': password},
              requiresAuth: false,
            )
            as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(responseDataObject(response));
    _onRefreshToken(tokens.refreshToken);
    _onRtdbToken(tokens.rtdbToken);
    return tokens;
  }

  Future<AuthTokens> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response =
        await _request(
              'POST',
              '/v1/auth/register',
              body: {
                'email': email,
                'password': password,
                'username': username,
              },
              requiresAuth: false,
            )
            as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(responseDataObject(response));
    _onRefreshToken(tokens.refreshToken);
    _onRtdbToken(tokens.rtdbToken);
    return tokens;
  }

  /// Exchanges a refresh token for a new ID token and RTDB token.
  /// Updates the stored RTDB token; the caller is responsible for updating
  /// their [AuthTokenProvider] with the returned [RefreshedTokens.idToken].
  Future<RefreshedTokens> refreshToken(String refreshToken) async {
    final response =
        await _request(
              'POST',
              '/v1/auth/refresh',
              body: {'refreshToken': refreshToken},
              requiresAuth: false,
            )
            as Map<String, dynamic>;
    final tokens = RefreshedTokens.fromJson(responseDataObject(response));
    _onRtdbToken(tokens.rtdbToken);
    return tokens;
  }

  Future<void> resendVerification(String idToken) async {
    await _request(
      'POST',
      '/v1/auth/resend-verification',
      body: {'idToken': idToken},
      requiresAuth: false,
    );
  }

  Future<({bool available, String? reason})> checkUsername(
    String username,
  ) async {
    final response =
        await _request(
              'POST',
              '/v1/auth/check-username',
              body: {'username': username},
              requiresAuth: false,
            )
            as Map<String, dynamic>;
    final data = responseDataObject(response);
    return (
      available: data['available'] as bool,
      reason: data['reason'] as String?,
    );
  }
}
