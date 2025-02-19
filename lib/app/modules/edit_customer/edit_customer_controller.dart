import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../manage_customers/manage_customers_controller.dart';

class EditCustomerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final lines = <DocumentSnapshot>[].obs;
  final selectedLineId = RxnString();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController ovenTypeController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  final String customerId;
  final Map<String, dynamic> customerData;

  EditCustomerController({
    required this.customerId,
    required this.customerData,
  });

  @override
  void onInit() {
    super.onInit();
    loadLines();
    initializeData();
  }

  void initializeData() {
    nameController.text = customerData['name'];
    phoneController.text = customerData['phone'] ?? '';
    nicknameController.text = customerData['nickname'] ?? '';
    ovenTypeController.text = customerData['ovenType'] ?? '';
    discountController.text = customerData['discount'].toString();
    selectedLineId.value = customerData['line']['id'];
  }

  Future<void> loadLines() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('lines').orderBy('name').get();
      lines.value = snapshot.docs;
    } catch (e) {
      print('Error loading lines: $e');
    }
  }

  Future<bool> isCustomerNameUnique(String name) async {
    final QuerySnapshot result = await _firestore
        .collection('customers')
        .where('name', isEqualTo: name)
        .get();

    return result.docs.isEmpty ||
        (result.docs.length == 1 && result.docs.first.id == customerId);
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

  Future<void> updateCustomer() async {
    if (nameController.text.trim().isEmpty) {
      showMessage(
        title: 'خطأ',
        message: 'يجب إدخال اسم العميل',
        success: false,
      );
      return;
    }

    if (phoneController.text.isNotEmpty) {
      if (!phoneController.text.startsWith('0') ||
          phoneController.text.length != 11) {
        showMessage(
          title: 'خطأ',
          message: 'رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ 0',
          success: false,
        );
        return;
      }
    }

    if (selectedLineId.value == null) {
      showMessage(
        title: 'خطأ',
        message: 'يجب اختيار خط السير',
        success: false,
      );
      return;
    }

    try {
      isLoading.value = true;

      if (nameController.text.trim() != customerData['name'] &&
          !await isCustomerNameUnique(nameController.text.trim())) {
        showMessage(
          title: 'خطأ',
          message: 'اسم العميل مستخدم بالفعل',
          success: false,
        );
        return;
      }

      final selectedLine = lines.firstWhere(
        (line) => line.id == selectedLineId.value,
      );

      await _firestore.collection('customers').doc(customerId).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'nickname': nicknameController.text.trim(),
        'ovenType': ovenTypeController.text.trim(),
        'discount': double.parse(
            discountController.text.isEmpty ? '0' : discountController.text),
        'line': {
          'id': selectedLine.id,
          'name': selectedLine['name'],
        },
      });

      // تحديث قائمة العملاء في صفحة الإدارة
      final manageCustomersController = Get.find<ManageCustomersController>();
      await manageCustomersController.loadCustomers();

      Get.back();
      showMessage(
        title: 'تم بنجاح',
        message: 'تم تحديث بيانات العميل بنجاح',
        success: true,
      );
    } catch (e) {
      showMessage(
        title: 'خطأ',
        message: 'فشل تحديث بيانات العميل',
        success: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    nicknameController.dispose();
    ovenTypeController.dispose();
    discountController.dispose();
    super.onClose();
  }
}
