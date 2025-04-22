import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'access_token_service.dart';
import 'package:flutter/foundation.dart';
import '../screens/cart_screen/order_success_modal.dart';
import 'package:flutter/material.dart';

class OrderService {
  final AccessTokenService _tokenService = AccessTokenService();

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required BuildContext context,
    String? paymentMethodId = '900000002',
    String? note = 'This is a mobile test order.',
  }) async {
    try {
      debugPrint('🚀 Creating order with following details:');
      debugPrint('📦 Items: ${jsonEncode(items)}');
      debugPrint('💳 Payment Method ID: $paymentMethodId');
      if (note != null) debugPrint('📝 Note: $note');

      final accessToken = await _tokenService.getValidAccessToken();

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      };

      final body = {
        "action": "order/create",
        "table-id": 2601205584233623,
        "payment_method_id": "900000002",
        "note": note ?? "Created for testing purposes.",
        "external-id": "EXT-12345",
        "items": items.isNotEmpty
            ? items
            : [
                {
                  "id": 7671912974527303,
                  "qty": 2,
                  "note": "Item note",
                  "tags": []
                }
              ],
        "lock": true,
      };
      if (note != null) body['note'] = note;

      debugPrint('📤 Sending request with headers: ${jsonEncode(headers)}');
      debugPrint('📤 Sending request with body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/clouds/${ApiConstants.cloudId}/branches/${ApiConstants.branchId}/pos-actions'),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('📥 Response status code: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      responseData['statusCode'] = response.statusCode;

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Order created successfully');
        return responseData;
      } else {
        debugPrint('❌ Failed to create order: ${response.statusCode}');
        debugPrint('❌ Error response: ${response.body}');
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Exception during order creation: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOrder(String orderId) async {
    final accessToken = await _tokenService.getValidAccessToken();

    final response = await http.get(
      Uri.parse(
          '${ApiConstants.baseUrl}/clouds/${ApiConstants.cloudId}/orders?filter=id|eq|$orderId&include=orderItems'),
      headers: {
        'Accept': 'application/json; charset=UTF-8',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0] ?? {};
    } else {
      throw Exception('Failed to get order: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateOrder({
    required String orderId,
    String? customerId,
    double discountPercent = 0,
    String? note,
    bool lock = true,
  }) async {
    final accessToken = await _tokenService.getAccessToken();

    final response = await http.post(
      Uri.parse(
          '${ApiConstants.baseUrl}/clouds/${ApiConstants.cloudId}/branches/${ApiConstants.branchId}/pos-actions'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'action': 'order/update',
        'order-id': orderId,
        // 'customer-id': customerId,
        'discount-percent': discountPercent,
        'note': note,
        'lock': lock,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update order: ${response.statusCode}');
    }
  }
}
