import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../routes/app_pages.dart';

class ReorderLinesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final lines = <DocumentSnapshot<Map<String, dynamic>>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLines();
  }

  Future<void> loadLines() async {
    try {
      isLoading.value = true;
      // نقوم بتحميل الخطوط مرتبة بالاسم مبدئياً
      final QuerySnapshot<Map<String, dynamic>> result =
          await _firestore.collection('lines').orderBy('name').get();

      // إذا لم يكن هناك حقل order، نقوم بإضافته
      if (result.docs.isNotEmpty && result.docs.first.data()['order'] == null) {
        final batch = _firestore.batch();
        for (int i = 0; i < result.docs.length; i++) {
          batch.update(result.docs[i].reference, {'order': i});
        }
        await batch.commit();
      }

      lines.value = result.docs;
    } catch (e) {
      print('Error loading lines: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الخطوط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLineOrder(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final DocumentSnapshot<Map<String, dynamic>> line = lines[oldIndex];
      lines.removeAt(oldIndex);
      lines.insert(newIndex, line);

      // تحديث الترتيب في قاعدة البيانات
      final batch = _firestore.batch();
      for (int i = 0; i < lines.length; i++) {
        batch.update(lines[i].reference, {'order': i});
      }
      await batch.commit();

      Get.snackbar(
        'تم بنجاح',
        'تم تحديث ترتيب الخطوط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      print('Error updating line order: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث الترتيب',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void showLineCustomers(DocumentSnapshot<Map<String, dynamic>> line) {
    final lineData = line.data()!;
    Get.toNamed(
      Routes.LINE_CUSTOMERS,
      arguments: {
        'lineData': lineData,
        'lineId': line.id,
      },
    );
  }

  // دالة منفصلة لعرض نافذة العملاء
  void showCustomersDialog(QuerySnapshot<Map<String, dynamic>> snapshot,
      Map<String, dynamic> lineData) {
    if (snapshot.docs.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('عملاء ${lineData['name']}'),
          content: const Text('لا يوجد عملاء مسجلين في هذا الخط'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('عملاء ${lineData['name']}'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.docs.length,
            onReorder: (oldIndex, newIndex) => updateCustomerOrder(
                snapshot.docs, oldIndex, newIndex, lineData['id']),
            itemBuilder: (context, index) {
              final customerDoc = snapshot.docs[index];
              final customer = customerDoc.data();
              return Card(
                key: ValueKey(customerDoc.id),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${(customer['orderInLine'] ?? index + 1)}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    customer['name'] ?? 'بدون اسم',
                    style: const TextStyle(
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
                      if (customer['ovenType']?.isNotEmpty == true)
                        Text('نوع الفرن: ${customer['ovenType']}'),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.drag_handle,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> updateCustomerOrder(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> customers,
    int oldIndex,
    int newIndex,
    String lineId,
  ) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final movedCustomer = customers[oldIndex];
      final batch = _firestore.batch();

      // تحديث ترتيب العميل المنقول
      batch.update(movedCustomer.reference, {'orderInLine': newIndex + 1});

      // تحديث ترتيب باقي العملاء
      final updatedCustomers =
          List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(customers);
      updatedCustomers.removeAt(oldIndex);
      updatedCustomers.insert(newIndex, movedCustomer);

      for (int i = 0; i < updatedCustomers.length; i++) {
        if (i != newIndex) {
          batch.update(updatedCustomers[i].reference, {'orderInLine': i + 1});
        }
      }

      await batch.commit();

      Get.snackbar(
        'تم بنجاح',
        'تم تحديث ترتيب العملاء',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );

      // إعادة تحميل العملاء
      showLineCustomers(lines.firstWhere((line) => line.id == lineId));
    } catch (e) {
      print('Error updating customer order: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث الترتيب',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void showCustomersReorder(DocumentSnapshot<Map<String, dynamic>> line) {
    final lineData = line.data()!;
    Get.toNamed(
      Routes.LINE_CUSTOMERS_REORDER,
      arguments: {
        'lineData': lineData,
        'lineId': line.id,
      },
    );
  }
}
