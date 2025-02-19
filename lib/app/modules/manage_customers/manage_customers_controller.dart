import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCustomersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final customers = <DocumentSnapshot>[].obs;
  final filteredCustomers = <DocumentSnapshot>[].obs;

  final searchController = TextEditingController();
  final searchType = 'name'.obs; // القيمة الافتراضية للبحث بالاسم

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot =
          await _firestore.collection('customers').orderBy('name').get();
      customers.value = snapshot.docs;
      filteredCustomers.value = snapshot.docs;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحميل بيانات العملاء',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomers.value = customers;
      return;
    }

    filteredCustomers.value = customers.where((customer) {
      final data = customer.data() as Map<String, dynamic>;
      switch (searchType.value) {
        case 'name':
          return data['name'].toString().contains(query);
        case 'phone':
          return data['phone'].toString().contains(query);
        case 'nickname':
          return data['nickname'].toString().contains(query);
        default:
          return false;
      }
    }).toList();
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection('customers').doc(customerId).delete();
      await loadCustomers();
      Get.snackbar(
        'تم بنجاح',
        'تم حذف العميل بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف العميل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
