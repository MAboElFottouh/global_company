import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'return_details_controller.dart';

class ReturnDetailsView extends GetView<ReturnDetailsController> {
  const ReturnDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مرتجع الفاتورة'),
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // معلومات الفاتورة والعميل
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'العميل: ${controller.invoiceData['customerName']}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (!controller.isLoadingCustomerData.value)
                      Text(
                        'المديونية السابقة: ${controller.customerDelayedBalance.value} جنيه',
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.customerDelayedBalance.value > 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // قائمة المنتجات
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    final hasDiscount =
                        product['discount'] != null && product['discount'] > 0;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['productName'].toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      'الكمية: ${product['originalQuantity']}'),
                                  Text('السعر: ${product['price']} جنيه'),
                                  if (hasDiscount)
                                    Text(
                                      'خصم: ${product['discount']}%',
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                  Text(
                                    'المرتجع: ${product['returnedQuantity']}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () => controller
                                      .decreaseReturnedQuantity(index),
                                  color: Colors.green,
                                ),
                                Text(
                                  '${product['returnedQuantity']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  onPressed: product['returnedQuantity'] <
                                          product['originalQuantity']
                                      ? () => controller
                                          .increaseReturnedQuantity(index)
                                      : null,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // إجمالي المرتجع وزر التأكيد
              if (controller.hasReturns)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        'إجمالي المبلغ المسترد: ${controller.totalReturnAmount.value} جنيه',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.confirmReturns(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'تأكيد المرتجع',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
