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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref
                  .read(allProductsStateProvider.notifier)
                  .refreshProducts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                ref.read(selectedCategoryProvider.notifier).state = null;
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ProductsService.categoryNames.length +
                  1, // +1 for "All Products"
              itemBuilder: (context, index) {
                // First chip is "All Products"
                if (index == 0) {
                  final isSelected = selectedCategory == null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: const Text('All Products'),
                      selected: isSelected,
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
                    selected: isSelected,
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
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  selectedCategory == null
                      ? 'All Products'
                      : productsService.getCategoryName(selectedCategory),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: MenuGrid()),
          const AddToCartButtonWidget(),
        ],
      ),
    );
  }
}
