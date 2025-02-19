import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageProductsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final products = <DocumentSnapshot>[].obs;
  final filteredProducts = <DocumentSnapshot>[].obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot =
          await _firestore.collection('products').orderBy('name').get();
      products.value = snapshot.docs;
      filteredProducts.value = snapshot.docs;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحميل بيانات المنتجات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.value = products;
      return;
    }

    filteredProducts.value = products.where((product) {
      final data = product.data() as Map<String, dynamic>;
      return data['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();
  }

  // دالة مساعدة لعرض الرسائل
  void showMessage({
    required String title,
    required String message,
    required bool success,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: success ? Colors.green[100] : Colors.red[100],
      colorText: success ? Colors.green[900] : Colors.red[900],
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').doc(productId).delete();

      showMessage(
        title: 'تم بنجاح',
        message: 'تم حذف المنتج بنجاح',
        success: true,
      );

      await loadProducts();
    } catch (e) {
      showMessage(
        title: 'خطأ',
        message: 'فشل حذف المنتج',
        success: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
