import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'inventory_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المخزن'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFBBDEFB)],
          ),
        ),
        child: Column(
          children: [
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.filterProducts,
                decoration: InputDecoration(
                  hintText: 'بحث عن منتج...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // قائمة المنتجات
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد منتجات',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = controller.filteredProducts[index];
                    final data = product.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // أيقونة المنتج
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.teal[700],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // معلومات المنتج
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // اسم المنتج وزر التعديل
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (controller.isAdmin)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              controller.updateStock(
                                            product.id,
                                            data['stock'] ?? 0,
                                            context,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // معلومات السعر والمخزون
                                  Text('سعر البيع: ${data['price']} جنيه'),
                                  Obx(() {
                                    final lastPurchasePrice = controller
                                            .lastPurchasePrices[product.id] ??
                                        0;
                                    return Text(
                                      lastPurchasePrice > 0
                                          ? 'آخر سعر شراء: $lastPurchasePrice جنيه'
                                          : 'لم يتم شراء هذا المنتج من قبل',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // حالة المخزون والكمية
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: _getStockColor(data['stock'] ?? 0)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getStockStatus(data['stock'] ?? 0),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _getStockColor(data['stock'] ?? 0),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${data['stock'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _getStockColor(data['stock'] ?? 0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock <= 0) {
      return Colors.red;
    } else if (stock <= 10) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getStockStatus(int stock) {
    if (stock <= 0) {
      return 'غير متوفر';
    } else if (stock <= 10) {
      return 'منخفض';
    } else {
      return 'متوفر';
    }
  }
}
