class AuthTokens {
  final String idToken;
  final String refreshToken;
  final String rtdbToken;

  const AuthTokens({
    required this.idToken,
    required this.refreshToken,
    required this.rtdbToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        idToken: json['idToken'] as String,
        refreshToken: json['refreshToken'] as String,
        rtdbToken: json['rtdbToken'] as String,
      );
}

class RefreshedTokens {
  final String idToken;
  final String rtdbToken;

  const RefreshedTokens({required this.idToken, required this.rtdbToken});

  factory RefreshedTokens.fromJson(Map<String, dynamic> json) =>
      RefreshedTokens(
        idToken: json['idToken'] as String,
        rtdbToken: json['rtdbToken'] as String,
      );
}
