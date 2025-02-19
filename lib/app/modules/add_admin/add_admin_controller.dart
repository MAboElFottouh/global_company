import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAdminController extends GetxController {
  final isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final selectedRole = 'admin'.obs;

  // قائمة الصلاحيات المتاحة
  final List<Map<String, String>> roles = [
    {'value': 'admin', 'label': 'مسؤول'},
    {'value': 'storekeeper', 'label': 'أمين مخزن'},
    {'value': 'delegate', 'label': 'مندوب'},
  ];

  // التحقق من أن رقم الهاتف غير مستخدم
  Future<bool> _isPhoneNumberUnique(String phoneNumber) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('userNumber', isEqualTo: phoneNumber)
        .get();

    return result.docs.isEmpty;
  }

  Future<void> addAdmin(String name, String phoneNumber) async {
    isLoading.value = true;
    try {
      // التحقق من أن رقم الهاتف غير مستخدم
      if (!await _isPhoneNumberUnique(phoneNumber)) {
        Get.snackbar(
          'خطأ',
          'رقم الهاتف مستخدم بالفعل',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.red),
        );
        return;
      }

      // إنشاء بريد إلكتروني افتراضي باستخدام رقم الهاتف
      String email = '$phoneNumber@globalcompany.com';
      String defaultPassword = '123456';

      // إنشاء حساب المستخدم في Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: defaultPassword,
      );

      // إضافة بيانات المستخدم في Firestore مع الصلاحية المحددة
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'userNumber': phoneNumber,
        'email': email,
        'role': selectedRole.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // إظهار رسالة النجاح وانتظار لحظة قبل العودة
      await Get.snackbar(
        'نجاح',
        'تم إضافة المسؤول بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      // انتظار لحظة لضمان ظهور الرسالة
      await Future.delayed(const Duration(seconds: 1));

      // العودة للصفحة السابقة
      Get.back();
    } catch (e) {
      String errorMessage = 'فشل إضافة المسؤول';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
            break;
          case 'invalid-email':
            errorMessage = 'البريد الإلكتروني غير صالح';
            break;
          case 'operation-not-allowed':
            errorMessage = 'تسجيل المستخدمين غير مفعل';
            break;
          case 'weak-password':
            errorMessage = 'كلمة المرور ضعيفة جداً';
            break;
        }
      }
      Get.snackbar(
        'خطأ',
        errorMessage,
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
}
