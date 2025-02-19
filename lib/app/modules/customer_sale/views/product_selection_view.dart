import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../customer_sale_controller.dart';

class ProductSelectionView extends GetView<CustomerSaleController> {
  final List<Map<String, dynamic>> products;

  const ProductSelectionView({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'اختر المنتج',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          children: [
            // شريط البحث
            TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // يمكن إضافة وظيفة البحث لاحقاً
              },
            ),
            const SizedBox(height: 16),
            // قائمة المنتجات
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        product['productName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('المتاح: ${product['availableQuantity']} قطعة'),
                          Text(
                            'السعر: ${product['price']} جنيه',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: controller.isProductSelected(product['productId'])
                          ? IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.orange[700],
                              onPressed: () {
                                Get.back();
                                final index = controller.getProductIndex(product['productId']);
                                if (index != -1) {
                                  controller.scrollToProduct(index);
                                }
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: Colors.blue[700],
                              onPressed: () => controller.addProduct(product),
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