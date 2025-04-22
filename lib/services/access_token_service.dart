import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/access_token_response.dart';
import 'package:flutter/foundation.dart';

class AccessTokenService {
  static const int maxRetries = 3;

  Future<AccessTokenResponse> getAccessToken() async {
    debugPrint('🔑 Requesting new access token');
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/signin/token'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'User ${ApiConstants.refreshToken}',
      },
      body: jsonEncode({
        '_cloudId': ApiConstants.cloudId,
      }),
    );

    debugPrint('📥 Token response status code: ${response.statusCode}');
    debugPrint('📥 Token response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode <= 201) {
      final responseData = jsonDecode(response.body);
      debugPrint(
          '✅ Access token obtained successfully: ${responseData['accessToken']}');
      return AccessTokenResponse.fromJson(responseData);
    } else {
      debugPrint('❌ Failed to get access token: ${response.statusCode}');
      throw Exception('Failed to get access token: ${response.statusCode}');
    }
  }

  Future<String> getValidAccessToken() async {
    debugPrint('🔄 Getting valid access token');
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final tokenResponse = await getAccessToken();
        debugPrint('✅ Valid access token retrieved');
        return tokenResponse.accessToken;
      } catch (e) {
        retryCount++;
        debugPrint('⚠️ Token retrieval attempt $retryCount failed: $e');
        if (retryCount < maxRetries) {
          debugPrint('⏳ Waiting before retry...');
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          debugPrint('❌ All token retrieval attempts failed');
          rethrow;
        }
      }
    }
    throw Exception(
        'Failed to get valid access token after $maxRetries attempts');
  }
}
