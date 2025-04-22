import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import 'product_providers.dart';

// State for product counters
class CounterState {
  final Map<String, int> counters;

  CounterState({Map<String, int>? counters}) : counters = counters ?? {};

  CounterState copyWith({
    Map<String, int>? counters,
  }) {
    return CounterState(
      counters: counters ?? this.counters,
    );
  }
}

// Counter provider
class CounterNotifier extends StateNotifier<CounterState> {
  final Ref _ref;

  CounterNotifier(this._ref) : super(CounterState()) {
    // Initialize counters when products are loaded
    _initializeCounters();
  }

  void _initializeCounters() {
    // Get all products and initialize their counters to 0
    final products = _ref.read(allProductsStateProvider).value ?? [];
    final initialCounters = <String, int>{};
    for (final product in products) {
      initialCounters[product.id] = 0;
    }
    state = CounterState(counters: initialCounters);
  }

  void increment(String productId) {
    final currentCount = state.counters[productId] ?? 0;
    state = CounterState(
      counters: {...state.counters, productId: currentCount + 1},
    );
  }

  void decrement(String productId) {
    final currentCount = state.counters[productId] ?? 0;
    if (currentCount > 0) {
      state = CounterState(
        counters: {...state.counters, productId: currentCount - 1},
      );
    }
  }

  void reset(String productId) {
    state = CounterState(
      counters: {...state.counters, productId: 0},
    );
  }

  void resetAll() {
    _initializeCounters();
  }
}

// Provider for the counter state
final counterProvider =
    StateNotifierProvider<CounterNotifier, CounterState>((ref) {
  return CounterNotifier(ref);
});

// Provider for individual product counters
final productCounterProvider = Provider.family<int, Product>((ref, product) {
  final counters = ref.watch(counterProvider);
  return counters.counters[product.id] ?? 0;
});
