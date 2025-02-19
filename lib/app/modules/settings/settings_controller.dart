import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/session_service.dart';

class SettingsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final userData = Rxn<Map<String, dynamic>>();
  final isAdmin = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final sessionService = Get.find<SessionService>();
      userData.value = sessionService.currentUser;
      isAdmin.value = userData.value?['role'] == 'admin';
      nameController.text = userData.value?['name'];
      phoneController.text = userData.value?['userNumber'];
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<bool> isPhoneNumberUnique(String phoneNumber) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final result = await _firestore
        .collection('users')
        .where('userNumber', isEqualTo: phoneNumber)
        .get();

    return result.docs.isEmpty ||
        (result.docs.length == 1 && result.docs.first.id == currentUser.uid);
  }

  Future<bool> updateUserData() async {
    if (phoneController.text.length != 11) {
      Get.snackbar(
        'خطأ',
        'رقم الهاتف يجب أن يكون 11 رقم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return false;
    }

    if (!await isPhoneNumberUnique(phoneController.text)) {
      Get.snackbar(
        'خطأ',
        'رقم الهاتف مستخدم بالفعل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return false;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': nameController.text,
          'userNumber': phoneController.text,
        });

        // إغلاق النافذة أولاً
        Get.back();

        // ثم إظهار رسالة النجاح
        Get.snackbar(
          'تم بنجاح',
          'تم تحديث البيانات بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );

        await loadUserData();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث البيانات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePassword() async {
    if (newPasswordController.text.length < 6) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور يجب أن تكون 6 أرقام على الأقل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return false;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور الجديدة غير متطابقة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return false;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final email = '${userData.value!['userNumber']}@globalcompany.com';
        final credential = EmailAuthProvider.credential(
          email: email,
          password: oldPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPasswordController.text);

        // إغلاق النافذة أولاً
        Get.back();

        // ثم إظهار رسالة النجاح
        Get.snackbar(
          'تم بنجاح',
          'تم تغيير كلمة المرور بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );

        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور القديمة غير صحيحة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      final sessionService = Get.find<SessionService>();
      sessionService.clearSession();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> changePassword() async {
    // TODO: تنفيذ تغيير كلمة المرور
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
