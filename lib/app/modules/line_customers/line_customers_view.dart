import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'line_customers_controller.dart';

class LineCustomersView extends GetView<LineCustomersController> {
  const LineCustomersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
            () => Text('عملاء ${controller.lineData.value?['name'] ?? ''}')),
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

          if (controller.customers.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد عملاء مسجلين في هذا الخط',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.customers.length,
            onReorder: controller.updateCustomerOrder,
            itemBuilder: (context, index) {
              final customerDoc = controller.customers[index];
              final customer = customerDoc.data()!;
              return Card(
                key: ValueKey(customerDoc.id),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${customer['orderInLine'] ?? index + 1}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer['name'] ?? 'بدون اسم',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (customer['nickname']?.isNotEmpty == true)
                                  Text(
                                    'اللقب: ${customer['nickname']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (customer['phone']?.isNotEmpty == true)
                                  Text(
                                    'رقم الهاتف: ${customer['phone']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.shopping_cart),
                                    onPressed: () =>
                                        controller.startSale(customerDoc),
                                    tooltip: 'بيع',
                                    color: Colors.green,
                                  ),
                                  const Positioned(
                                    right: 8,
                                    bottom: 8,
                                    child: Icon(
                                      Icons.add_circle,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.shopping_cart),
                                    onPressed: () =>
                                        controller.startReturn(customerDoc),
                                    tooltip: 'مرتجع',
                                    color: Colors.red,
                                  ),
                                  const Positioned(
                                    right: 8,
                                    bottom: 8,
                                    child: Icon(
                                      Icons.remove_circle,
                                      size: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
