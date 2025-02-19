import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../delegate_delivery_form_controller.dart';
import '../../../models/selected_product.dart';

class ProductSelectionView extends GetView<DelegateDeliveryFormController> {
  final List<Map<String, dynamic>> products;

  const ProductSelectionView({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.8,
          maxWidth: Get.width * 0.9,
        ),
        child: Column(
          children: [
            const Text(
              'اختر منتج',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد منتجات متاحة',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final bool isSelected =
                            controller.isProductSelected(product['productId']);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(product['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('السعر: ${product['price']} جنيه'),
                                Text('المتاح: ${product['stock']} قطعة'),
                              ],
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      if (!isSelected) {
                                        controller.addProduct(product);
                                      }
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
