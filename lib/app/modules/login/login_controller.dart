import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../services/firebase_service.dart';
import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final _firebaseService = Get.find<FirebaseService>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // التحقق من بيانات المطور
  bool _isDeveloperLogin(String userNumber, String password) {
    return userNumber == '4040' && password == '001230';
  }

  Future<void> login(String userNumber, String password) async {
    isLoading.value = true;
    try {
      // تحقق من أن المدخل رقم
      if (int.tryParse(userNumber) == null) {
        Get.snackbar(
          'خطأ',
          'الرجاء إدخال رقم مستخدم صحيح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.red),
        );
        return;
      }

      // التحقق من بيانات المطور أولاً
      if (_isDeveloperLogin(userNumber, password)) {
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.SUPER_ADMIN);
        return;
      }

      // في حالة عدم تطابق بيانات المطور، نتحقق من Firebase
      try {
        await _firebaseService.signIn(userNumber, password);
        final userDoc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (userDoc.exists) {
          // حفظ بيانات المستخدم في الجلسة
          await Get.find<SessionService>().saveUserSession(userDoc);

          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['role'] == 'super_admin') {
            Get.offAllNamed(Routes.SUPER_ADMIN);
          } else {
            Get.offAllNamed(Routes.HOME);
          }
        }
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'بيانات تسجيل الدخول غير صحيحة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
}
