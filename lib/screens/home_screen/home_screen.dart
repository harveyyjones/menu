import 'package:big_szef_menu/screens/Home%20Screen%20UI/widgets/add_to_cart_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Home Screen UI/widgets/menu_grid.dart';
import '../../providers/product_providers.dart';
import '../../services/products_service.dart';
import '../cart_screen/cart_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final productsService = ProductsService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Menu',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: theme.colorScheme.primary,
            ),
            onPressed: () async {
              await ref
                  .read(allProductsStateProvider.notifier)
                  .refreshProducts();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon:
                      Icon(Icons.search, color: theme.colorScheme.primary),
                  suffixIcon: Consumer(builder: (context, ref, _) {
                    final query = ref.watch(searchQueryProvider);
                    if (query.isEmpty) return const SizedBox.shrink();

                    return IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    );
                  }),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                  ref.read(selectedCategoryProvider.notifier).state = null;
                },
              ),
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.only(top: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ProductsService.categoryNames.length +
                    1, // +1 for "All Products"
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  // First chip is "All Products"
                  if (index == 0) {
                    final isSelected = selectedCategory == null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: const Text('All Products'),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selected: isSelected,
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        ),
                        elevation: isSelected ? 2 : 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                null;
                          }
                        },
                      ),
                    );
                  }

                  // Adjust index for the category map
                  final actualIndex = index - 1;
                  final categoryId =
                      ProductsService.categoryNames.keys.elementAt(actualIndex);
                  final isSelected = categoryId == selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(productsService.getCategoryName(categoryId)),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey[300]!,
                        ),
                      ),
                      elevation: isSelected ? 2 : 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              categoryId;
                        } else {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                selectedCategory == null
                    ? 'All Products'
                    : productsService.getCategoryName(selectedCategory),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),
            const Expanded(child: MenuGrid()),
            const AddToCartButtonWidget(),
          ],
        ),
      ),
    );
  }
}
