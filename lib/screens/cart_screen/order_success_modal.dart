import 'package:flutter/material.dart';

class OrderSuccessModal extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  const OrderSuccessModal({
    super.key,
    required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    final order = orderDetails['order'] ?? {};
    final items = orderDetails['items'] ?? [];
    final orderNumber = order['order-number'] ?? 'N/A';
    final tableNote = order['note'] ?? 'N/A';

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Your order has been created successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Order Number:', orderNumber),
          _buildInfoRow('Table:', tableNote.replaceAll('Table ID: ', '')),
          const SizedBox(height: 20),
          const Text(
            'Ordered Items:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final String? note = item['note'];

                return ListTile(
                  title: Text(item['name'] ?? 'Unknown Item'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${item['qty']}'),
                      if (note != null && note.isNotEmpty)
                        Text(
                          'Variant: $note',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${item['price-with-vat']?['total']?.toStringAsFixed(2) ?? '0.00'} zł',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  isThreeLine: note != null && note.isNotEmpty,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Return to Home',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
