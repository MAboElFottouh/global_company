import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../routes/app_pages.dart';
import '../../auth/auth_controller.dart';

class LineCustomersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final customers = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final isLoading = false.obs;
  final lineData = Rxn<Map<String, dynamic>>();
  final lineId = ''.obs;
  final delegateName = ''.obs;
  final discount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

    if (args == null) {
      print('Error: No arguments received');
      Get.back();
      Get.snackbar(
        'خطأ',
        'بيانات غير مكتملة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // التحقق من وجود البيانات المطلوبة
    if (args['lineData'] == null || args['lineId'] == null) {
      print('Error: Missing required arguments');
      print('Arguments received: $args');
      Get.back();
      Get.snackbar(
        'خطأ',
        'بيانات غير مكتملة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    lineData.value = args['lineData'];
    lineId.value = args['lineId'];
    delegateName.value =
        args['delegateName'] ?? ''; // استخدام قيمة افتراضية فارغة
    discount.value = (args['discount'] as num?)?.toDouble() ??
        0.0; // استخدام قيمة افتراضية 0.0

    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;
      final QuerySnapshot<Map<String, dynamic>> customersSnapshot =
          await _firestore
              .collection('customers')
              .where('line.id', isEqualTo: lineId.value)
              .get();

      if (customersSnapshot.docs.isNotEmpty) {
        bool needsOrderUpdate = false;
        for (var doc in customersSnapshot.docs) {
          if (doc.data()['orderInLine'] == null) {
            needsOrderUpdate = true;
            break;
          }
        }

        if (needsOrderUpdate) {
          final batch = _firestore.batch();
          final sortedCustomers = customersSnapshot.docs
            ..sort((a, b) =>
                (a.data()['name'] ?? '').compareTo(b.data()['name'] ?? ''));

          for (int i = 0; i < sortedCustomers.length; i++) {
            batch.update(sortedCustomers[i].reference, {'orderInLine': i + 1});
          }
          await batch.commit();
        }
      }

      final sortedSnapshot = await _firestore
          .collection('customers')
          .where('line.id', isEqualTo: lineId.value)
          .orderBy('orderInLine', descending: false)
          .get();

      customers.value = sortedSnapshot.docs;
    } catch (e) {
      print('Error loading line customers: $e');
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

  Future<void> updateCustomerOrder(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final movedCustomer = customers[oldIndex];
      final batch = _firestore.batch();

      batch.update(movedCustomer.reference, {'orderInLine': newIndex + 1});

      customers.removeAt(oldIndex);
      customers.insert(newIndex, movedCustomer);

      for (int i = 0; i < customers.length; i++) {
        if (i != newIndex) {
          batch.update(customers[i].reference, {'orderInLine': i + 1});
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

  void startSale(DocumentSnapshot customer) async {
    final authController = Get.find<AuthController>();
    if (authController.user == null) {
      Get.snackbar(
        'خطأ',
        'يجب تسجيل الدخول أولاً',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // التحقق من وجود منتجات مع المندوب
    final QuerySnapshot deliveriesSnapshot = await FirebaseFirestore.instance
        .collection('delegate_deliveries')
        .where('delegateId', isEqualTo: authController.user!.uid)
        .get();

    if (deliveriesSnapshot.docs.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا يوجد منتجات متاحة مع المندوب',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final data = customer.data() as Map<String, dynamic>;

    // التأكد من وجود جميع البيانات المطلوبة
    final String delegateNameValue = delegateName.value.isNotEmpty
        ? delegateName.value
        : (authController.user!.displayName ??
            authController.user!.email ??
            'مندوب');

    if (data['name'] == null) {
      print('Error: Missing customer name');
      print('Customer data: $data');
      Get.snackbar(
        'خطأ',
        'بيانات العميل غير مكتملة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    Get.toNamed(
      Routes.CUSTOMER_SALE,
      arguments: {
        'customerId': customer.id,
        'customerName': data['name'],
        'delegateId': authController.user!.uid,
        'delegateName': delegateNameValue,
        'discount': discount.value,
      },
    );
  }

  void openSalePage(String customerId, String customerName) {
    Get.toNamed(
      Routes.CUSTOMER_SALE,
      arguments: {
        'customerId': customerId,
        'customerName': customerName,
        'delegateId': lineId.value,
        'delegateName': delegateName.value,
        'discount': discount.value,
      },
    );
  }

  void startReturn(QueryDocumentSnapshot customerDoc) {
    final customer = customerDoc.data() as Map<String, dynamic>;
    Get.toNamed('/customer-returns', arguments: {
      'customerId': customerDoc.id,
      'customerName': customer['name'],
    });
  }
}
