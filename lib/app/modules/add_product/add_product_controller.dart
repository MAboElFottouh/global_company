import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_service.dart';

class AddProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController packagesCountController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final canSellPackages = false.obs;
  final packagePrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    stockController.text = '0';
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

    return result.docs.isEmpty;
  }

  Future<String> _generateProductId() async {
    final QuerySnapshot result = await _firestore
        .collection('products')
        .orderBy('productId', descending: true)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return '1001';
    }

    final lastId = int.parse(result.docs.first['productId'].toString());
    return (lastId + 1).toString();
  }

  Future<void> addProduct() async {
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
        'يجب إدخال عدد البواكي في الكرتونة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      isLoading.value = true;

      if (!await isProductNameUnique(nameController.text.trim())) {
        Get.snackbar(
          'خطأ',
          'اسم المنتج مستخدم بالفعل',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      final sessionService = Get.find<SessionService>();
      final userData = sessionService.currentUser;

      if (userData != null) {
        final productId = await _generateProductId();

        await _firestore.collection('products').add({
          'productId': productId,
          'name': nameController.text.trim(),
          'price': double.parse(priceController.text.trim()),
          'canSellPackages': canSellPackages.value,
          'packagesCount': canSellPackages.value
              ? int.parse(packagesCountController.text.trim())
              : 0,
          'packagePrice': packagePrice.value,
          'stock': int.parse(stockController.text.trim()),
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': {
            'uid': userData['uid'],
            'name': userData['name'],
            'role': userData['role'],
          },
        });

        Get.back();
        Get.snackbar(
          'تم بنجاح',
          'تم إضافة المنتج برقم: $productId',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إضافة المنتج',
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
