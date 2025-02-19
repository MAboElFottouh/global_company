import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../manage_products/manage_products_controller.dart';

class EditProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController packagesCountController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final canSellPackages = false.obs;
  final packagePrice = 0.0.obs;

  final String productId;
  final Map<String, dynamic> productData;

  EditProductController({
    required this.productId,
    required this.productData,
  });

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  void initializeData() {
    nameController.text = productData['name'];
    priceController.text = productData['price'].toString();
    canSellPackages.value = productData['canSellPackages'];
    stockController.text = (productData['stock'] ?? 0).toString();
    if (canSellPackages.value) {
      packagesCountController.text = productData['packagesCount'].toString();
      packagePrice.value = productData['packagePrice'];
    }
  }

  void updatePackagePrice() {
    if (canSellPackages.value &&
        priceController.text.isNotEmpty &&
        packagesCountController.text.isNotEmpty) {
      try {
        final price = double.parse(priceController.text);
        final count = int.parse(packagesCountController.text);
        if (count > 0) {
          packagePrice.value = price / count;
        }
      } catch (e) {
        packagePrice.value = 0.0;
      }
    } else {
      packagePrice.value = 0.0;
    }
  }

  Future<bool> isProductNameUnique(String name) async {
    final QuerySnapshot result = await _firestore
        .collection('products')
        .where('name', isEqualTo: name)
        .get();

    return result.docs.isEmpty ||
        (result.docs.length == 1 && result.docs.first.id == productId);
  }

  Future<void> updateProduct() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إدخال اسم المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    if (priceController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إدخال سعر المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    if (canSellPackages.value && packagesCountController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إدخال عدد الأجزاء في المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      isLoading.value = true;

      if (nameController.text.trim() != productData['name'] &&
          !await isProductNameUnique(nameController.text.trim())) {
        Get.snackbar(
          'خطأ',
          'اسم المنتج مستخدم بالفعل',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      await _firestore.collection('products').doc(productId).update({
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'canSellPackages': canSellPackages.value,
        'packagesCount': canSellPackages.value
            ? int.parse(packagesCountController.text.trim())
            : 0,
        'packagePrice': packagePrice.value,
        'stock': int.parse(stockController.text.trim()),
      });

      // تحديث قائمة المنتجات في صفحة الإدارة
      final manageProductsController = Get.find<ManageProductsController>();
      await manageProductsController.loadProducts();

      Get.back();
      Get.snackbar(
        'تم بنجاح',
        'تم تحديث بيانات المنتج رقم: ${productData['productId']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث بيانات المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    packagesCountController.dispose();
    stockController.dispose();
    super.onClose();
  }
}
