import 'package:flutter/material.dart';
import '../../../models/selected_product.dart';

class ProductCard extends StatefulWidget {
  final SelectedProduct product;
  final Function(int) onQuantityChanged;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onQuantityChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _quantityController.text = widget.product.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.product.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('السعر: ${widget.product.price} جنيه'),
                const Spacer(),
                Text('المتاح: ${widget.product.availableQuantity}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('الكمية:'),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      final quantity = int.tryParse(value) ?? 0;
                      if (quantity <= widget.product.availableQuantity) {
                        widget.onQuantityChanged(quantity);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'الإجمالي: ${widget.product.total.toStringAsFixed(2)} جنيه',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 