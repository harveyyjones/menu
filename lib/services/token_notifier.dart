import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'token_state.dart';
import 'access_token_service.dart';

class TokenNotifier extends StateNotifier<TokenState> {
  final AccessTokenService _tokenService;

  TokenNotifier(this._tokenService) : super(TokenState()) {
    fetchToken();
  }

  Future<void> fetchToken() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _tokenService.getAccessToken();
      state = state.copyWith(token: token, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void refreshToken() {
    fetchToken();
  }
}

final tokenNotifierProvider =
    StateNotifierProvider<TokenNotifier, TokenState>((ref) {
  final tokenService = AccessTokenService();
  return TokenNotifier(tokenService);
});
