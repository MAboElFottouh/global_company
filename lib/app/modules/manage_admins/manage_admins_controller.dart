import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageAdminsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final users = <DocumentSnapshot>[].obs;
  final userData = Rxn<DocumentSnapshot>();
  final editingUser = Rxn<DocumentSnapshot>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final selectedRole = 'admin'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadUserData();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['admin', 'storekeeper', 'delegate']).get();

      // ترتيب المستخدمين حسب الصلاحية
      users.value = snapshot.docs
        ..sort((a, b) {
          final roleOrder = {
            'admin': 1,
            'storekeeper': 2,
            'delegate': 3,
          };
          return roleOrder[a['role']]!.compareTo(roleOrder[b['role']]!);
        });
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحميل المستخدمين',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        userData.value = doc;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحميل بيانات المستخدم',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // التحقق من أن رقم الهاتف غير مستخدم
  Future<bool> isPhoneNumberUnique(
      String phoneNumber, String currentUserId) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('userNumber', isEqualTo: phoneNumber)
        .get();

    return result.docs.isEmpty ||
        (result.docs.length == 1 && result.docs.first.id == currentUserId);
  }

  void startEditing(DocumentSnapshot user) {
    editingUser.value = user;
    nameController.text = user['name'];
    phoneController.text = user['userNumber'];
    selectedRole.value = user['role'];
  }

  Future<bool> validateAndUpdate(String userId) async {
    if (phoneController.text.length != 11) {
      Get.snackbar(
        'خطأ',
        'رقم الهاتف يجب أن يكون 11 رقم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    if (!await isPhoneNumberUnique(phoneController.text, userId)) {
      Get.snackbar(
        'خطأ',
        'رقم الهاتف مستخدم بالفعل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'name': nameController.text,
        'userNumber': phoneController.text,
        'role': selectedRole.value,
      });

      editingUser.value = null;
      await loadUsers();

      // إغلاق النافذة أولاً ثم إظهار رسالة النجاح
      Get.back();

      Get.snackbar(
        'نجاح',
        'تم تحديث البيانات بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث البيانات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      Get.snackbar(
        'نجاح',
        'تم حذف المستخدم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
      await loadUsers();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف المستخدم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }
}
