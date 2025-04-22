import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_providers.dart';
import '../../services/order_service.dart';
import 'order_success_modal.dart';
import '../home_screen/home_screen.dart';

class CheckoutButtonWidget extends StatefulWidget {
  const CheckoutButtonWidget({super.key});

  @override
  State<CheckoutButtonWidget> createState() => _CheckoutButtonWidgetState();
}

class _CheckoutButtonWidgetState extends State<CheckoutButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const TablesWidget(),
        );
      },
      child: Container(
        width: 240,
        height: 70,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        child: const Center(
          child: Text(
            'Continue Order',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class TablesWidget extends StatefulWidget {
  const TablesWidget({super.key});

  @override
  State<TablesWidget> createState() => _TablesWidgetState();
}

class _TablesWidgetState extends State<TablesWidget> {
  int? selectedTable;
  bool isLoading = false;
  final OrderService _orderService = OrderService();

  Future<void> _createOrder(BuildContext context, WidgetRef ref) async {
    if (selectedTable == null) return;

    setState(() => isLoading = true);

    try {
      final cart = ref.read(cartProvider);

      final items = cart.items
          .map((item) => {
                'id': int.parse(item.product.id),
                'qty': item.quantity,
                'note': 'Item note',
                'tags': [],
              })
          .toList();

      debugPrint('🛒 Preparing order with ${items.length} items');

      final response = await _orderService.createOrder(
        context: context,
        items: items,
        paymentMethodId: '900000002',
        note: 'Table ID: $selectedTable',
      );

      debugPrint('📊 Order creation response received');

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        debugPrint('✅ Order created successfully');
        if (mounted) {
          Navigator.pop(context);
          ref.read(cartProvider.notifier).clearCart();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );

          if (true) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => OrderSuccessModal(orderDetails: response),
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create order')),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a Table',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(30, (index) {
                  final tableNumber = index + 1;
                  return ChoiceChip(
                    label: Text('Table $tableNumber'),
                    selected: selectedTable == tableNumber,
                    onSelected: (selected) {
                      setState(() {
                        selectedTable = selected ? tableNumber : null;
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedTable == tableNumber
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              if (selectedTable != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : () => _createOrder(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
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
