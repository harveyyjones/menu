import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_theme.dart';
import '../features/menu/providers/menu_provider.dart';
import '../features/cart/providers/cart_provider.dart';
import '../features/menu/models/menu_item.dart';

class MenuItemGrid extends ConsumerWidget {
  final String category;

  const MenuItemGrid({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = ref.watch(menuItemsByCategoryProvider(category));
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate number of columns based on screen width
    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
    }

    if (menuItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.disabledBackground,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.disabledBackground,
                        child: const Icon(
                          Icons.error_outline,
                          color: AppTheme.accent,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTheme.subheadingStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${item.price.toStringAsFixed(2)} TL',
                            style: AppTheme.priceStyle,
                          ),
                          const Spacer(),
                          Text(
                            '${item.gram}g',
                            style: AppTheme.bodyStyle.copyWith(
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.rating.toString(),
                            style: AppTheme.bodyStyle,
                          ),
                          const Spacer(),
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: AppTheme.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.cookTimeMinutes} min',
                            style: AppTheme.bodyStyle.copyWith(
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(
                                  item.id,
                                  item.name,
                                  item.price,
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 