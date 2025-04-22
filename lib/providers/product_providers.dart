import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/web.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';

// Service provider
final productsServiceProvider = Provider<ProductsService>((ref) {
  return ProductsService();
});

// State management for all products
final allProductsStateProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(ref.watch(productsServiceProvider));
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductsService _productsService;

  ProductsNotifier(this._productsService) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _productsService.getAllProducts();
      state = AsyncValue.data(products);
      print('Products loaded: ${products.length}');
      // Use a logging framework instead of print
      final logger = Logger();

      logger.log(
          Level.info,
          'Products: ${products.map((product) => {
                'name': product.name,
                'category': product.categoryId,
              }).join(', ')}');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }
}

// Filtered products by category
final filteredProductsProvider =
    Provider.family<List<Product>, String?>((ref, categoryId) {
  final productsAsync = ref.watch(allProductsStateProvider);

  return productsAsync.when(
    data: (products) {
      if (categoryId == null) return products;
      return products
          .where((product) => product.categoryId == categoryId)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Product details by ID
final productByIdProvider = Provider.family<Product?, String>((ref, productId) {
  final productsAsync = ref.watch(allProductsStateProvider);

  return productsAsync.when(
    data: (products) => products.firstWhere(
      (product) => product.id == productId,
      orElse: () => throw Exception('Product not found'),
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Loading state provider
final isLoadingProvider = Provider<bool>((ref) {
  final productsState = ref.watch(allProductsStateProvider);
  return productsState.isLoading;
});

// Error state provider
final errorProvider = Provider<String?>((ref) {
  final productsState = ref.watch(allProductsStateProvider);
  return productsState.error?.toString();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
