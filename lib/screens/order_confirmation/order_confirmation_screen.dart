import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final int tableNumber;
  final List<CartItem> items;
  final double totalAmount;

  const OrderConfirmationScreen({
    Key? key,
    required this.tableNumber,
    required this.items,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: Text('Order Confirmation', style: AppTheme.headingStyle),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table $tableNumber',
                          style: AppTheme.subheadingStyle,
                        ),
                        const Divider(),
                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: AppTheme.bodyStyle,
                                    ),
                                    Text(
                                      '${item.quantity}x',
                                      style: AppTheme.bodyStyle.copyWith(
                                        color: AppTheme.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(item.price * item.quantity).toStringAsFixed(2)} TL',
                                style: AppTheme.priceStyle,
                              ),
                            ],
                          ),
                        )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: AppTheme.subheadingStyle,
                            ),
                            Text(
                              '${totalAmount.toStringAsFixed(2)} TL',
                              style: AppTheme.priceStyle.copyWith(
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement order placement
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Place Order'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
} 