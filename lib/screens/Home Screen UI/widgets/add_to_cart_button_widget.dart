import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/counter_providers.dart';
import '../../../providers/cart_providers.dart';
import '../../../providers/product_providers.dart';
import '../../../providers/product_variants_provider.dart';
import '../../../widgets/product_variant_modal.dart';
import '../../../models/product_model.dart';
import '../../../screens/cart_screen/cart_screen.dart';

class AddToCartButtonWidget extends ConsumerWidget {
  const AddToCartButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters = ref.watch(counterProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = ref.watch(filteredProductsProvider(selectedCategory));
    final theme = Theme.of(context);

    // Calculate total items with quantity > 0
    final totalItems = products
        .where((product) => (counters.counters[product.id] ?? 0) > 0)
        .length;

    if (totalItems == 0) {
      return const SizedBox(height: 80); // Maintain space when empty
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
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
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: theme.colorScheme.primary,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined),
              const SizedBox(width: 8),
              Text(
                'Add to Cart',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  totalItems.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
