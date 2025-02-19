import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'line_customers_reorder_controller.dart';

class LineCustomersReorderView extends GetView<LineCustomersReorderController> {
  const LineCustomersReorderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.hasChanges.value) {
          final result = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('تنبيه'),
              content: const Text('هل أنت متأكد من الخروج بدون حفظ التغييرات؟'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('خروج'),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() =>
              Text('ترتيب عملاء ${controller.lineData.value?['name'] ?? ''}')),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (controller.hasChanges.value) {
                final result = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('تنبيه'),
                    content: const Text(
                        'هل أنت متأكد من الخروج بدون حفظ التغييرات؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('خروج'),
                      ),
                    ],
                  ),
                );
                if (result ?? false) {
                  Get.back();
                }
              } else {
                Get.back();
              }
            },
          ),
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
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.withOpacity(0.1),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'أدخل رقم الترتيب المطلوب للعميل',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن عميل...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) =>
                          controller.searchQuery.value = value,
                    ),
                  ],
                ),
              ),
              Expanded(
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

                  final displayedCustomers = controller.filteredCustomers;
                  if (displayedCustomers.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد نتائج للبحث',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedCustomers.length,
                    itemBuilder: (context, index) {
                      final customerDoc = displayedCustomers[index];
                      final customer = customerDoc.data()!;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${customer['orderInLine'] ?? index + 1}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            customer['name'] ?? 'بدون اسم',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customer['nickname']?.isNotEmpty == true)
                                Text('اللقب: ${customer['nickname']}'),
                              if (customer['phone']?.isNotEmpty == true)
                                Text('رقم الهاتف: ${customer['phone']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'الترتيب',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    controller.setTempOrder(
                                        customerDoc.id, value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.swap_horiz),
                                onPressed: () {
                                  final value =
                                      controller.tempOrders[customerDoc.id];
                                  if (value != null && value.isNotEmpty) {
                                    final newOrder = int.tryParse(value);
                                    if (newOrder != null && newOrder > 0) {
                                      controller.updateCustomerOrder(
                                        customerDoc,
                                        newOrder - 1,
                                      );
                                    }
                                  }
                                },
                                tooltip: 'نقل للترتيب المحدد',
                                color: Colors.blue,
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
        floatingActionButton: Obx(
          () => FloatingActionButton.extended(
            onPressed: controller.hasChanges.value
                ? () => controller.saveOrder()
                : null,
            icon: const Icon(Icons.save),
            label: const Text('حفظ الترتيب'),
            backgroundColor:
                controller.hasChanges.value ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }
}
