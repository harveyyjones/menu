import 'dart:convert';
import 'package:big_szef_menu/models/product_model.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/pagination_response.dart';
import 'access_token_service.dart';

class ProductsService {
  final AccessTokenService _tokenService = AccessTokenService();
  static const int itemsPerPage = 100;
  static const int maxRetries = 3;

  // Map of category IDs to their names
  static const Map<String, String> categoryNames = {
    "2874782105126736": "Lunch Specials",
    "7924259690533458": "Pide & Flatbreads",
    "2830655616219967": "Take-Away & Frozen Products",
    "4078841834436231": "Set Menus",
    "2283081661746334": "Traditional Kebabs",
    "2101013732277269": "Staff Meals",
    "2843317209624504": "Food By Weight",
    "2825712141696239": "Mix Menus",
    "2099725266714925": "Premium Steaks",
    "1653237571772537": "Main Kebab Dishes",
    "7670922984809134": "Side Dishes & Appetizers",
    "1949517300993574": "Coffee & Hot Beverages",
    "3124409899328264": "Tips & Service",
    "63305493851571": "Miscellaneous Services",
    "7671905788986539": "Cold Beverages",
    "7670845620036187": "Specialty Meat Dishes",
    "8881336408050611": "Combo Meals",
    "9001428386544587": "Soft Drinks",
    "7670951039593938": "Breakfast Items",
    "1501777224320907": "Iftar Menus",
    "7671898326034106": "Desserts",
    "1596986484267301": "Packaging",
    "7670442227889934": "Thin Bread Wraps",
    "7670469055330847": "Thick Bread Wraps",
    "7670804923370095": "Box Meals",
    "7670816063018618": "Plated Kebabs",
    "7670908513183131": "Burgers",
    "7670932636258454": "Salads",
    "7703181545821438": "Soups"
  };

  Future<List<Product>> getAllProducts() async {
    List<Product> allProducts = [];
    int currentPage = 1;
    bool hasMorePages = true;
    int retryCount = 0;

    while (hasMorePages) {
      try {
        final accessToken = await _getValidAccessToken();
        final response = await http.get(
          Uri.parse(
            '${ApiConstants.baseUrl}/clouds/${ApiConstants.cloudId}/products?page=$currentPage&limit=$itemsPerPage',
          ),
          headers: {
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final paginationResponse = PaginationResponse<Product>.fromJson(
            jsonDecode(response.body),
            (json) => Product.fromJson(json),
          );

          allProducts.addAll(paginationResponse.data);

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
          throw Exception('Failed to get products: ${response.statusCode}');
        }
      } catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          continue;
        }
        rethrow;
      }
    }

    return allProducts;
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

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final allProducts = await getAllProducts();
    return allProducts
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  /// Returns the category name for a given category ID.
  /// Returns 'Unknown Category' if the ID is not found.
  String getCategoryName(String categoryId) {
    return categoryNames[categoryId] ?? 'Unknown Category';
  }
}
