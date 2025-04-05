import 'package:big_szef_menu/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/category_scroll.dart';
import '../../components/menu_item_grid.dart';
import '../../features/cart/providers/cart_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> _categories = [
    'All',
    'Food',
    'Drinks',
    'Desserts',
  ];
  
  String _selectedCategory = 'All';
  
  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider).items;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: Text('Menu', style: AppTheme.headingStyle),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: AppTheme.primaryText),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartItems.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              // TODO: Implement cart navigation
            },
          ),
        ],
      ),
      body: isWideScreen
          ? Row(
              children: [
                SizedBox(
                  width: 200,
                  child: CategoryScroll(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    isVertical: true,
                  ),
                ),
                Expanded(
                  child: MenuItemGrid(
                    category: _selectedCategory,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                CategoryScroll(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
                Expanded(
                  child: MenuItemGrid(
                    category: _selectedCategory,
                  ),
                ),
              ],
            ),
    );
  }
} 