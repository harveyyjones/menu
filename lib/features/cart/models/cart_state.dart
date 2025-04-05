class CartState {
  final Map<String, CartItem> items;

  const CartState({
    this.items = const {},
  });
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
} 