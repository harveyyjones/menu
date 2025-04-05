import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_state.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(String id, String name, double price) {
    final currentItems = {...state.items};
    
    if (currentItems.containsKey(id)) {
      final item = currentItems[id]!;
      currentItems[id] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: item.quantity + 1,
      );
    } else {
      currentItems[id] = CartItem(
        id: id,
        name: name,
        price: price,
        quantity: 1,
      );
    }

    state = CartState(items: currentItems);
  }

  void removeItem(String id) {
    final currentItems = {...state.items};
    currentItems.remove(id);
    state = CartState(items: currentItems);
  }

  void clear() {
    state = const CartState();
  }
} 