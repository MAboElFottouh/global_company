import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/session_service.dart';

class AddLineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final isLoading = false.obs;
  final TextEditingController nameController = TextEditingController();

  // التحقق من أن اسم الخط غير مستخدم
  Future<bool> isLineNameUnique(String name) async {
    final QuerySnapshot result = await _firestore
        .collection('lines')
        .where('name', isEqualTo: name)
        .get();

    return result.docs.isEmpty;
  }

  Future<void> addLine() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إدخال اسم الخط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    try {
      isLoading.value = true;

      // التحقق من أن اسم الخط غير مستخدم
      if (!await isLineNameUnique(nameController.text.trim())) {
        Get.snackbar(
          'خطأ',
          'اسم الخط مستخدم بالفعل',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.red),
        );
        return;
      }

      final sessionService = Get.find<SessionService>();
      final userData = sessionService.currentUser;

      if (userData != null) {
        await _firestore.collection('lines').add({
          'name': nameController.text.trim(),
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
          'تم إضافة الخط بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إضافة الخط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
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
