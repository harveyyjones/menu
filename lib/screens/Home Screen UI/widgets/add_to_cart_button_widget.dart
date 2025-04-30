import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/counter_providers.dart';
import '../../../providers/cart_providers.dart';
import '../../../providers/product_providers.dart';
import '../../../providers/product_variants_provider.dart';
import '../../../widgets/product_variant_modal.dart';
import '../../../models/product_model.dart';

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
            ? () async {
                // Collect products that need variant selection
                final productsNeedingVariants = <Product>[];

                for (final product in products) {
                  final quantity = counters.counters[product.id] ?? 0;
                  if (quantity > 0 && productHasVariants(product)) {
                    productsNeedingVariants.add(product);
                    ref
                        .read(productVariantSelectionProvider.notifier)
                        .addProductToCustomize(product);
                  }
                }

                // If we have products needing variants, show the modal
                if (productsNeedingVariants.isNotEmpty) {
                  // Process one product at a time
                  for (final product in productsNeedingVariants) {
                    final confirmed =
                        await showProductVariantModal(context, product);

                    // If user cancelled, stop the process
                    if (confirmed != true) {
                      return;
                    }
                  }
                }

                // Add all items to cart with their variants if applicable
                for (final product in products) {
                  final quantity = counters.counters[product.id] ?? 0;
                  if (quantity > 0) {
                    // Get selected variant if any
                    String? selectedVariant;
                    if (productHasVariants(product)) {
                      selectedVariant = ref
                          .read(productVariantSelectionProvider)
                          .selectedVariants[product.id];

                      // If variant wasn't selected, skip this product
                      if (selectedVariant == null) continue;
                    }

                    // Add to cart with variant info
                    ref.read(cartProvider.notifier).addItem(
                          product,
                          quantity,
                          selectedVariant: selectedVariant,
                        );
                  }
                }

                // Reset all counters and clear variant selections
                ref.read(counterProvider.notifier).resetAll();
                ref.read(productVariantSelectionProvider.notifier).clear();

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
