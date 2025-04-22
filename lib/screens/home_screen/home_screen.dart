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
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ProductsService.categoryNames.length,
              itemBuilder: (context, index) {
                final categoryId =
                    ProductsService.categoryNames.keys.elementAt(index);
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
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Expanded(child: MenuGrid()),
          const AddToCartButtonWidget(),
        ],
      ),
    );
  }
}
