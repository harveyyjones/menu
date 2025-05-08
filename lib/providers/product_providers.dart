import 'package:big_szef_menu/services/get_tables_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/web.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';
import '../models/table_model.dart';

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
      final logger = Logger();

      logger.log(Level.info, 'Products loaded: ${products.length}');

      logger.log(
          Level.info,
          'Products: ${products.map((product) => {
                'name': product.name,
                'display': product.display,
              }).join(', ')}');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }
}

// List of categories to hide from customers
final List<String> hiddenCategories = [
  '2101013732277269', // Staff Meals
];

// Provider for all visible products (without any filtering except hidden categories)
final allVisibleProductsProvider = Provider<List<Product>>((ref) {
  final productsAsync = ref.watch(allProductsStateProvider);

  return productsAsync.when(
    data: (products) {
      return products
          .where((product) =>
              product.display == true &&
              !hiddenCategories.contains(product.categoryId))
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Filtered products by category
final filteredProductsProvider =
    Provider.family<List<Product>, String?>((ref, categoryId) {
  final productsAsync = ref.watch(allProductsStateProvider);
  final searchText = ref.watch(searchQueryProvider).toLowerCase();

  return productsAsync.when(
    data: (products) {
      List<Product> filteredProducts;

      // If no category is selected (All Products view), show all products except hidden categories
      if (categoryId == null) {
        filteredProducts = products
            .where((product) =>
                !hiddenCategories.contains(product.categoryId) &&
                product.display == true)
            .toList();
      }
      // When category is selected, apply normal filters
      else {
        filteredProducts = products
            .where((product) =>
                product.display == true &&
                product.categoryId == categoryId &&
                !hiddenCategories.contains(product.categoryId))
            .toList();
      }

      // Filter by search text
      if (searchText.isNotEmpty) {
        print('Search input entered: $searchText');
        print('Filtered products before search: ${filteredProducts.length}');

        filteredProducts = filteredProducts
            .where((product) => product.name.toLowerCase().contains(searchText))
            .toList();

        print('Filtered products after search: ${filteredProducts.length}');
        print(
            'Filtered products: ${filteredProducts.map((product) => '🍽️ ' + product.name).join(', ')}');
      }

      return filteredProducts;
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

final searchQueryProvider = StateProvider<String>((ref) => '');

// Service provider
final tableServiceProvider = Provider<TableService>((ref) {
  return TableService();
});

// State management for all tables
final allTablesStateProvider =
    StateNotifierProvider<TablesNotifier, AsyncValue<List<TableModel>>>((ref) {
  return TablesNotifier(ref.watch(tableServiceProvider));
});

class TablesNotifier extends StateNotifier<AsyncValue<List<TableModel>>> {
  final TableService _tableService;

  TablesNotifier(this._tableService) : super(const AsyncValue.loading()) {
    loadTables();
  }

  Future<void> loadTables() async {
    try {
      state = const AsyncValue.loading();
      final tables = await _tableService.getAllTables();
      state = AsyncValue.data(tables);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Selected table provider
final selectedTableProvider = StateProvider<TableModel?>((ref) => null);
