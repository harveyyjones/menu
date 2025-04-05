import 'package:big_szef_menu/constants/app_theme.dart';
import 'package:flutter/material.dart';

class CategoryScroll extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool isVertical;

  const CategoryScroll({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isVertical = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isVertical
        ? ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _CategoryButton(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => onCategorySelected(category),
                ),
              );
            },
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _CategoryButton(
                    category: category,
                    isSelected: isSelected,
                    onTap: () => onCategorySelected(category),
                  ),
                );
              }).toList(),
            ),
          );
  }
}

class _CategoryButton extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent : AppTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.accent : AppTheme.border,
              width: 1,
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.primaryText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
} 