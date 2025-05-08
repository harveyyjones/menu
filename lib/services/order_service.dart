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
    required int tableId,
    List<String>? variantNotes,
  }) async {
    try {
      debugPrint('🚀 Creating order');
      debugPrint('📦 Items count: ${items.length}');
      debugPrint('🪑 Table ID: $tableId');

      // Log the items with their notes/variants
      for (var item in items) {
        debugPrint(
            '📋 Item ID: ${item['id']}, Quantity: ${item['qty']}, Note: ${item['note']}');
      }

      final accessToken = await _tokenService.getValidAccessToken();

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      };

      final body = {
        "action": "order/create",
        "table-id": tableId,
        "payment-method-id": paymentMethodId,
        "note": note.toString() +
                "  TABLE NUMBER:" +
                tableId.toString() +
                "ONLINE ORDER" ??
            "ONLINE ORDER",
        "external-id": "External Id.",
        "items": items,
        "print-append": "Test print",
        "print-config": {
          "characters": 14,
          "print-mini": true,
          "print-logo": true,
          "font": 1
        },
        "print-type": "local",
        "take-away": false
      };

      debugPrint(
          '📤 REQUEST BODY: ${const JsonEncoder.withIndent('  ').convert(body)}');
      debugPrint(
          '📤 REQUEST HEADERS: ${const JsonEncoder.withIndent('  ').convert(headers)}');

      final response = await http
          .post(
            Uri.parse(
                '${ApiConstants.baseUrl}/clouds/${ApiConstants.cloudId}/branches/${ApiConstants.branchId}/pos-actions'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      // Print complete response information
      debugPrint('==================================================');
      debugPrint('📥 RESPONSE STATUS CODE: ${response.statusCode}');
      debugPrint(
          '📥 RESPONSE HEADERS: ${const JsonEncoder.withIndent('  ').convert(response.headers)}');
      debugPrint('📥 RESPONSE BODY: ${response.body}');
      debugPrint('==================================================');

      final responseData = jsonDecode(response.body);
      responseData['statusCode'] = response.statusCode;

      // Print formatted JSON
      debugPrint(
          '📥 PARSED RESPONSE: ${const JsonEncoder.withIndent('  ').convert(responseData)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Order created successfully');
        return responseData;
      } else {
        debugPrint('❌ Failed to create order: ${response.statusCode}');
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error during order creation: $e');
      throw Exception('Error creating order: $e');
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
