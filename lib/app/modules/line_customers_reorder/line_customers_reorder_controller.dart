import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LineCustomersReorderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final customers = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final isLoading = false.obs;
  final lineData = Rxn<Map<String, dynamic>>();
  final lineId = ''.obs;
  final hasChanges = false.obs;
  final searchQuery = ''.obs;
  final filteredCustomers = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final tempOrders = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments;
    lineData.value = args['lineData'];
    lineId.value = args['lineId'];
    loadCustomers();
    ever(searchQuery, (_) => filterCustomers());
  }

  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;
      final QuerySnapshot<Map<String, dynamic>> customersSnapshot =
          await _firestore
              .collection('customers')
              .where('line.id', isEqualTo: lineId.value)
              .orderBy('orderInLine', descending: false)
              .get();

      customers.value = customersSnapshot.docs;
      filterCustomers();
    } catch (e) {
      print('Error loading customers: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل العملاء',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setTempOrder(String customerId, String order) {
    tempOrders[customerId] = order;
  }

  void updateCustomerOrder(
    QueryDocumentSnapshot<Map<String, dynamic>> customer,
    int newIndex,
  ) {
    if (newIndex < 0 || newIndex >= customers.length) {
      Get.snackbar(
        'تنبيه',
        'الرقم المدخل غير صحيح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
      );
      return;
    }

    final currentIndex = customers.indexOf(customer);
    if (currentIndex == -1) return;

    // نحصل على العميل الذي سيتم تبديله
    final otherCustomer = customers.firstWhere(
      (doc) => doc.data()['orderInLine'] == newIndex + 1,
      orElse: () => customer,
    );

    if (otherCustomer.id != customer.id) {
      // تبديل الترتيب بين العميلين
      final currentOrder = customer.data()['orderInLine'] ?? (currentIndex + 1);
      final batch = _firestore.batch();

      // تحديث ترتيب العميل الأول
      batch.update(customer.reference, {'orderInLine': newIndex + 1});
      // تحديث ترتيب العميل الثاني
      batch.update(otherCustomer.reference, {'orderInLine': currentOrder});

      // تنفيذ التحديثات
      batch.commit().then((_) {
        tempOrders.remove(customer.id); // حذف القيمة المؤقتة
        loadCustomers(); // إعادة تحميل البيانات
        hasChanges.value = true;

        Get.snackbar(
          'تم بنجاح',
          'تم تبديل ترتيب العملاء',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }).catchError((e) {
        print('Error swapping customers: $e');
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء تبديل ترتيب العملاء',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      });
    }
  }

  Future<void> saveOrder() async {
    try {
      if (!hasChanges.value) {
        return;
      }

      isLoading.value = true;
      final batch = _firestore.batch();

      for (int i = 0; i < customers.length; i++) {
        batch.update(customers[i].reference, {'orderInLine': i + 1});
      }

      await batch.commit();
      hasChanges.value = false;

      // إعادة تحميل البيانات بعد الحفظ
      await loadCustomers();

      Get.snackbar(
        'تم بنجاح',
        'تم حفظ ترتيب العملاء',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      print('Error saving order: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ الترتيب',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterCustomers() {
    if (searchQuery.value.isEmpty) {
      filteredCustomers.value = customers;
    } else {
      filteredCustomers.value = customers.where((doc) {
        final customer = doc.data();
        final name = customer['name']?.toString().toLowerCase() ?? '';
        final nickname = customer['nickname']?.toString().toLowerCase() ?? '';
        final phone = customer['phone']?.toString().toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();

        return name.contains(query) ||
            nickname.contains(query) ||
            phone.contains(query);
      }).toList();
    }
  }
}
