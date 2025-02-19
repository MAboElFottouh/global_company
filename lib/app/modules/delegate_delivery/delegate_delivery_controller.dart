import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/selected_product.dart';
import '../../routes/app_pages.dart';
import '../../auth/auth_controller.dart';

class DelegateDeliveryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final delegates = <DocumentSnapshot>[].obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final filteredDelegates = <DocumentSnapshot>[].obs;
  final selectedProducts = <SelectedProduct>[].obs;
  final totalQuantity = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDelegates();
  }

  Future<void> loadDelegates() async {
    try {
      isLoading.value = true;
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'delegate')
          .get();

      // جلب معلومات إضافية لكل مندوب
      final List<DocumentSnapshot> updatedDelegates = [];
      for (var delegate in result.docs) {
        final delegateData = delegate.data() as Map<String, dynamic>;

        // جلب منتجات المندوب
        final QuerySnapshot<Map<String, dynamic>> deliveriesSnapshot =
            await _firestore
                .collection('delegate_deliveries')
                .where('delegateId', isEqualTo: delegate.id)
                .get();

        int totalQuantity = 0;
        double totalValue = 0.0;

        if (deliveriesSnapshot.docs.isNotEmpty) {
          final doc = deliveriesSnapshot.docs.first;
          final Map<String, dynamic> data = doc.data();
          final List<dynamic> products = data['products'] ?? [];

          // حساب إجمالي الكميات والقيمة
          for (var product in products) {
            final int quantity = product['quantity'] as int;
            final double price = (product['price'] as num).toDouble();
            totalQuantity += quantity;
            totalValue += quantity * price;
          }
        }

        // تحديث بيانات المندوب
        await _firestore.collection('users').doc(delegate.id).update({
          'totalQuantity': totalQuantity,
          'totalValue': totalValue,
        });

        // جلب الوثيقة المحدثة
        final updatedDelegate =
            await _firestore.collection('users').doc(delegate.id).get();

        updatedDelegates.add(updatedDelegate);
      }

      delegates.value = updatedDelegates;
      filteredDelegates.value = updatedDelegates;
    } catch (e) {
      print('Error loading delegates: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل المناديب',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterDelegates(String query) {
    if (query.isEmpty) {
      filteredDelegates.value = delegates;
      return;
    }

    filteredDelegates.value = delegates.where((delegate) {
      final data = delegate.data() as Map<String, dynamic>;
      final name = data['name'].toString().toLowerCase();
      final phone = data['userNumber'].toString();
      return name.contains(query.toLowerCase()) || phone.contains(query);
    }).toList();
  }

  void showDelegateProducts(DocumentSnapshot delegate) {
    final data = delegate.data() as Map<String, dynamic>;
    Get.toNamed(
      Routes.DELEGATE_PRODUCTS,
      arguments: {
        'delegateId': delegate.id,
        'delegateName': data['name'],
      },
    );
  }

  void startDelivery(DocumentSnapshot delegate) {
    final data = delegate.data() as Map<String, dynamic>;
    Get.toNamed(
      Routes.DELEGATE_DELIVERY_FORM,
      arguments: {
        'delegateId': delegate.id,
        'delegateName': data['name'],
        'currentBalance': (data['currentBalance'] ?? 0.0).toDouble(),
      },
    );
  }

  void openLineCustomers(DocumentSnapshot line) {
    final data = line.data() as Map<String, dynamic>;
    final authController = Get.find<AuthController>();

    if (authController.user == null) {
      Get.snackbar(
        'خطأ',
        'يجب تسجيل الدخول أولاً',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      Routes.LINE_CUSTOMERS,
      arguments: {
        'lineData': data,
        'lineId': line.id,
        'delegateName': authController.user!.displayName ??
            authController.user!.email ??
            'مندوب',
        'discount': data['discount'] ?? 0.0,
      },
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
