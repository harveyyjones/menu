import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../providers/product_variants_provider.dart';

class ProductVariantModal extends ConsumerWidget {
  final Product product;

  const ProductVariantModal({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVariant =
        ref.watch(productVariantSelectionProvider).selectedVariants[product.id];

    return Container(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Product image and info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              if (product.imageUrlSubtitle != null &&
                  product.imageUrlSubtitle!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrlSubtitle!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 16),

              // Product name and price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.priceWithVat.toStringAsFixed(2)} zł',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Required choice text
          const Text(
            'Select option',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Options list
          if (product.notes != null && product.notes!.isNotEmpty)
            ...product.notes!.map((variant) => RadioListTile<String>(
                  title: Text(variant),
                  value: variant,
                  groupValue: selectedVariant,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(productVariantSelectionProvider.notifier)
                          .selectVariant(product.id, value);
                    }
                  },
                  activeColor: Theme.of(context).primaryColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                )),

          const SizedBox(height: 24),

          // Add to Cart button
          ElevatedButton(
            onPressed: selectedVariant != null
                ? () {
                    Navigator.of(context).pop(true);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add to Cart',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// Function to show the modal
Future<bool?> showProductVariantModal(BuildContext context, Product product) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductVariantModal(product: product),
  );
}
