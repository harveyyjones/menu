import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

// State for a single product's quantity
class ProductQuantity {
  final Product product;
  final int quantity;

  ProductQuantity({
    required this.product,
    required this.quantity,
  });
}

// State for the entire cart
class CartState {
  final List<ProductQuantity> items;

  CartState({List<ProductQuantity>? items}) : items = items ?? [];

  CartState copyWith({
    List<ProductQuantity>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }
}

// Cart provider
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem(Product product, int quantity) {
    state = CartState(
      items: [
        ...state.items,
        ProductQuantity(product: product, quantity: quantity)
      ],
    );
  }

  void removeItem(String productId) {
    state = CartState(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void clearCart() {
    state = CartState();
  }
}

// Provider for the cart state
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Provider for individual product quantities
final productQuantityProvider = Provider.family<int, Product>((ref, product) {
  final cart = ref.watch(cartProvider);
  final item = cart.items.firstWhere(
    (item) => item.product.id == product.id,
    orElse: () => ProductQuantity(product: product, quantity: 0),
  );
  return item.quantity;
});
