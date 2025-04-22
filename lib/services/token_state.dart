import '../models/access_token_response.dart';

class TokenState {
  final AccessTokenResponse? token;
  final bool isLoading;
  final String? error;

  TokenState({
    this.token,
    this.isLoading = false,
    this.error,
  });

  TokenState copyWith({
    AccessTokenResponse? token,
    bool? isLoading,
    String? error,
  }) {
    return TokenState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
