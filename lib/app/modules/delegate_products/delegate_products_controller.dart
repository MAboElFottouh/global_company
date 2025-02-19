import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DelegateProductsController extends GetxController {
  final delegateId = ''.obs;
  final delegateName = ''.obs;
  final isLoading = true.obs;
  final products = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    delegateId.value = args['delegateId'];
    delegateName.value = args['delegateName'];
    loadDelegateProducts();
  }

  Future<void> loadDelegateProducts() async {
    try {
      isLoading.value = true;

      // جلب تسليمات المندوب
      final QuerySnapshot<Map<String, dynamic>> deliveriesSnapshot =
          await FirebaseFirestore.instance
              .collection('delegate_deliveries')
              .where('delegateId', isEqualTo: delegateId.value)
              .get();

      print('Found ${deliveriesSnapshot.docs.length} deliveries');

      if (deliveriesSnapshot.docs.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'لا يوجد منتجات مع هذا المندوب',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
        );
        return;
      }

      // جلب آخر تسليم للمندوب
      final doc = deliveriesSnapshot.docs.first;
      final deliveryData = doc.data();
      final List<dynamic> deliveryProducts = deliveryData['products'] ?? [];

      print('Processing delivery: ${doc.id} at ${deliveryData['createdAt']}');
      print('Products in delivery: ${deliveryProducts.length}');

      // تحويل المنتجات إلى الشكل المطلوب
      products.value = deliveryProducts
          .where((product) => (product['quantity'] as int) > 0)
          .map((product) => {
                'productId': product['productId'],
                'name': product['productName'],
                'price': product['price'],
                'quantity': product['quantity'],
              })
          .toList();

      print('\nDeliveries total:');
      products.forEach((product) {
        print('${product['name']}: ${product['quantity']}');
      });

      // ترتيب المنتجات حسب الاسم
      products
          .sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل المنتجات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }
}
