import 'dart:convert';
import 'package:big_szef_menu/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/pagination_response.dart';
import '../models/table_model.dart';
import 'access_token_service.dart';

class TableService {
  final AccessTokenService _tokenService = AccessTokenService();
  static const int itemsPerPage = 100;
  static const int maxRetries = 3;

  Future<List<TableModel>> getAllTables() async {
    List<TableModel> allTables = [];
    int currentPage = 1;
    bool hasMorePages = true;
    int retryCount = 0;

    while (hasMorePages) {
      try {
        final accessToken = await _getValidAccessToken();
        final response = await http.get(
          Uri.parse(
            '${ApiConstants.baseUrl}/clouds/${ApiConstants.cloudId}/tables?page=$currentPage&limit=$itemsPerPage',
          ),
          headers: {
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final paginationResponse = PaginationResponse<TableModel>.fromJson(
            jsonDecode(response.body),
            (json) => TableModel.fromJson(json),
          );

          allTables.addAll(paginationResponse.data);

          if (paginationResponse.nextPage == null ||
              currentPage >= paginationResponse.lastPage) {
            hasMorePages = false;
          } else {
            currentPage++;
          }
          // Reset retry count on successful request
          retryCount = 0;
        } else if (response.statusCode == 403 && retryCount < maxRetries) {
          // Token might be invalid, try refreshing
          retryCount++;
          continue;
        } else {
          throw Exception('Failed to get tables: ${response.statusCode}');
        }
      } catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          continue;
        }
        rethrow;
      }
    }

    return allTables;
  }

  Future<String> _getValidAccessToken() async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final tokenResponse = await _tokenService.getAccessToken();
        return tokenResponse.accessToken;
      } catch (e) {
        if (retryCount < maxRetries - 1) {
          retryCount++;
          // Add a small delay before retrying
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          rethrow;
        }
      }
    }
    throw Exception(
        'Failed to get valid access token after $maxRetries attempts');
  }
}
