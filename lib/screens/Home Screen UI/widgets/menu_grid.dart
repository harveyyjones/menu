import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_model.dart';
import '../../../providers/product_providers.dart';
import '../../../providers/counter_providers.dart';
import '../../../providers/cart_providers.dart';

class MenuGrid extends ConsumerWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = ref.watch(filteredProductsProvider(selectedCategory));
    final searchText = ref.watch(searchQueryProvider);

    // Show a loading indicator when there are no products yet
    if (products.isEmpty) {
      // Check if we're still loading or if there's truly no products
      final isLoading = ref.watch(isLoadingProvider);

      if (isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_food, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              searchText.isNotEmpty
                  ? 'No products match your search'
                  : 'No products in this category',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Use a different grid layout for All Products view (more compact)
    final isAllProducts = selectedCategory == null;

    // For All Products view, show a count of displayed products
    if (isAllProducts) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Showing ${products.length} products',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isAllProducts ? 2 : 2,
                childAspectRatio: isAllProducts ? 0.7 : 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return MenuItemCard(
                  product: product,
                  isCompact: isAllProducts,
                );
              },
            ),
          ),
        ],
      );
    }

    // Regular category view
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return MenuItemCard(
          product: product,
          isCompact: false,
        );
      },
    );
  }
}

class MenuItemCard extends ConsumerWidget {
  final Product product;
  final bool isCompact;

  const MenuItemCard({
    super.key,
    required this.product,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(productCounterProvider(product));
    final hasImage = product.imageUrlSubtitle != null &&
        product.imageUrlSubtitle!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isCompact ? 8 : 12),
                  ),
                  child: hasImage
                      ? Image.network(
                          product.imageUrlSubtitle!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
                // Price badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      '${product.priceWithVat.toStringAsFixed(2)} zł',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // If no image, show display status badge
                if (!hasImage && !product.display)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hidden',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: isCompact ? 2 : 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.categoryId.isNotEmpty && !isCompact)
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 4.0),
                    //   child: Text(
                    //     'Cat ID: ${product.categoryId}',
                    //     style: TextStyle(
                    //       fontSize: 10,
                    //       color: Colors.grey.shade600,
                    //     ),
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ),
                    const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isCompact)
                        Text(
                          '${product.priceWithVat.toStringAsFixed(2)} zł',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          SizedBox(
                            width: isCompact ? 24 : 36,
                            height: isCompact ? 24 : 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: isCompact ? 16 : 20,
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: quantity > 0
                                  ? () => ref
                                      .read(counterProvider.notifier)
                                      .decrement(product.id)
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              quantity.toString(),
                              style: TextStyle(
                                fontSize: isCompact ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isCompact ? 24 : 36,
                            height: isCompact ? 24 : 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: isCompact ? 16 : 20,
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () => ref
                                  .read(counterProvider.notifier)
                                  .increment(product.id),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_photography,
              size: 40,
              color: Colors.grey,
            ),
            if (!isCompact)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'No Image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
