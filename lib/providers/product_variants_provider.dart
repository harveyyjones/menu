import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

// State for products requiring variant selection
class ProductVariantSelectionState {
  final List<Product> productsToCustomize;
  final Map<String, String> selectedVariants; // productId -> selected variant

  ProductVariantSelectionState({
    List<Product>? productsToCustomize,
    Map<String, String>? selectedVariants,
  })  : productsToCustomize = productsToCustomize ?? [],
        selectedVariants = selectedVariants ?? {};

  ProductVariantSelectionState copyWith({
    List<Product>? productsToCustomize,
    Map<String, String>? selectedVariants,
  }) {
    return ProductVariantSelectionState(
      productsToCustomize: productsToCustomize ?? this.productsToCustomize,
      selectedVariants: selectedVariants ?? this.selectedVariants,
    );
  }
}

class ProductVariantSelectionNotifier
    extends StateNotifier<ProductVariantSelectionState> {
  ProductVariantSelectionNotifier() : super(ProductVariantSelectionState());

  // Add a product that needs variant selection
  void addProductToCustomize(Product product) {
    if (!state.productsToCustomize.contains(product)) {
      state = state.copyWith(
        productsToCustomize: [...state.productsToCustomize, product],
      );
    }
  }

  // Select a variant for a product
  void selectVariant(String productId, String variant) {
    state = state.copyWith(
      selectedVariants: {...state.selectedVariants, productId: variant},
    );
  }

  // Check if all products have variants selected
  bool allProductsCustomized() {
    for (final product in state.productsToCustomize) {
      if (!state.selectedVariants.containsKey(product.id)) {
        return false;
      }
    }
    return true;
  }

  // Get selected variant for a product
  String? getSelectedVariant(String productId) {
    return state.selectedVariants[productId];
  }

  // Clear all products and selections
  void clear() {
    state = ProductVariantSelectionState();
  }
}

// Provider for product variant selection
final productVariantSelectionProvider = StateNotifierProvider<
    ProductVariantSelectionNotifier, ProductVariantSelectionState>((ref) {
  return ProductVariantSelectionNotifier();
});

// Helper function to check if a product has variants
bool productHasVariants(Product product) {
  return product.notes != null && product.notes!.isNotEmpty;
}
