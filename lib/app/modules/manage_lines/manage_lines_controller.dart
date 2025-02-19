import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageLinesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final lines = <DocumentSnapshot>[].obs;
  final TextEditingController nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadLines();
  }

  Future<void> loadLines() async {
    isLoading.value = true;
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('lines')
          .orderBy('createdAt', descending: true)
          .get();
      lines.value = snapshot.docs;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحميل الخطوط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> isLineNameUnique(String name, String currentId) async {
    final QuerySnapshot result = await _firestore
        .collection('lines')
        .where('name', isEqualTo: name)
        .get();

    return result.docs.isEmpty ||
        (result.docs.length == 1 && result.docs.first.id == currentId);
  }

  Future<void> updateLine(String lineId) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إدخال اسم الخط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    if (!await isLineNameUnique(nameController.text.trim(), lineId)) {
      Get.snackbar(
        'خطأ',
        'اسم الخط مستخدم بالفعل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      await _firestore.collection('lines').doc(lineId).update({
        'name': nameController.text.trim(),
      });

      Get.back();
      await loadLines();

      Get.snackbar(
        'تم بنجاح',
        'تم تحديث الخط بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث الخط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
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

  Future<void> deleteLine(String lineId) async {
    try {
      isLoading.value = true;

      final customersSnapshot = await _firestore
          .collection('customers')
          .where('line.id', isEqualTo: lineId)
          .get();

      if (customersSnapshot.docs.isNotEmpty) {
        showMessage(
          title: 'خطأ',
          message: 'لا يمكن حذف الخط لوجود عملاء مرتبطين به',
          success: false,
        );
        isLoading.value = false;
        return;
      }

      await _firestore.collection('lines').doc(lineId).delete();

      showMessage(
        title: 'تم بنجاح',
        message: 'تم حذف خط السير بنجاح',
        success: true,
      );

      await loadLines();
    } catch (e) {
      showMessage(
        title: 'خطأ',
        message: 'فشل حذف خط السير',
        success: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
