import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/counter_providers.dart';
import '../../../providers/cart_providers.dart';
import '../../../providers/product_providers.dart';

class AddToCartButtonWidget extends ConsumerWidget {
  const AddToCartButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters = ref.watch(counterProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = ref.watch(filteredProductsProvider(selectedCategory));

    // Calculate total items with quantity > 0
    final totalItems = products
        .where((product) => (counters.counters[product.id] ?? 0) > 0)
        .length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: totalItems > 0
            ? () {
                // Add all items with quantity > 0 to cart
                for (final product in products) {
                  final quantity = counters.counters[product.id] ?? 0;
                  if (quantity > 0) {
                    ref.read(cartProvider.notifier).addItem(product, quantity);
                  }
                }
                // Reset all counters
                ref.read(counterProvider.notifier).resetAll();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $totalItems items to cart'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Add to Cart'),
            if (totalItems > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  totalItems.toString(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
