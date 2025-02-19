import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manage_purchases_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;

class ManagePurchasesView extends GetView<ManagePurchasesController> {
  const ManagePurchasesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المشتريات'),
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
                onChanged: controller.filterPurchases,
                decoration: InputDecoration(
                  hintText: 'بحث برقم الفاتورة أو اسم المنتج...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // قائمة الفواتير
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredPurchases.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد فواتير',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.filteredPurchases.length,
                  itemBuilder: (context, index) {
                    final purchase = controller.filteredPurchases[index];
                    final data = purchase.data() as Map<String, dynamic>;
                    final createdAt = data['createdAt'] as Timestamp;
                    final date = intl.DateFormat('yyyy/MM/dd - HH:mm')
                        .format(createdAt.toDate());

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                'فاتورة #${data['invoiceNumber']}',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الإجمالي: ${data['total']} جنيه',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(date),
                        children: [
                          // تفاصيل المنتجات
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (data['items'] as List).length,
                            itemBuilder: (context, itemIndex) {
                              final item = (data['items'] as List)[itemIndex];
                              return ListTile(
                                title: Text(item['productName']),
                                subtitle: Text(
                                    'الكمية: ${item['quantity']} × ${item['price']} جنيه'),
                                trailing: Text(
                                  '${item['total']} جنيه',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          // معلومات إضافية
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'بواسطة: ${(data['createdBy'] as Map)['name']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                // إظهار زر الحذف فقط للمسؤولين
                                if (controller.isAdmin)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _showDeleteConfirmation(
                                        context, purchase.id),
                                  ),
                              ],
                            ),
                          ),
                        ],
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

  void _showDeleteConfirmation(BuildContext context, String purchaseId) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('تأكيد الحذف'),
          ],
        ),
        content: const Text(
            'هل أنت متأكد من حذف هذه الفاتورة؟\nسيتم تعديل المخزون تلقائياً.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel_outlined, color: Colors.grey),
                SizedBox(width: 5),
                Text('إلغاء', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePurchase(purchaseId);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline, color: Colors.red),
                SizedBox(width: 5),
                Text('حذف', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
