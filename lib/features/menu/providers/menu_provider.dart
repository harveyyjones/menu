import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item.dart';

final menuProvider = FutureProvider<List<MenuItem>>((ref) async {
  final String jsonString = await rootBundle.loadString('mock_data/product_list.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((item) => MenuItem.fromJson(item)).toList();
});

final menuItemsByCategoryProvider = Provider.family<List<MenuItem>, String>((ref, category) {
  final menuAsync = ref.watch(menuProvider);
  return menuAsync.when(
    data: (items) {
      if (category == 'All') return items;
      return items.where((item) => item.category == category).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}); 