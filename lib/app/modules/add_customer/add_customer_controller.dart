import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import '../review_customers/review_customers_controller.dart';
import '../review_customers/review_customers_view.dart';
import '../review_customers/review_customers_binding.dart';

// نموذج بيانات العميل
class CustomerData {
  final String name;
  final String? phone;
  final String? nickname;
  final String? ovenType;

  CustomerData({
    required this.name,
    this.phone,
    this.nickname,
    this.ovenType,
  });
}

class AddCustomerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final lines = <DocumentSnapshot>[].obs;
  final selectedLineId = RxnString();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController ovenTypeController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadLines();
    discountController.text = '0';
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

  // التحقق من أن اسم العميل غير مستخدم
  Future<bool> isCustomerNameUnique(String name) async {
    final QuerySnapshot result = await _firestore
        .collection('customers')
        .where('name', isEqualTo: name)
        .get();

    return result.docs.isEmpty;
  }

  Future<void> addCustomer() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إدخال اسم العميل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    if (phoneController.text.isNotEmpty) {
      if (!phoneController.text.startsWith('0') ||
          phoneController.text.length != 11) {
        Get.snackbar(
          'خطأ',
          'رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ 0',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }
    }

    if (selectedLineId.value == null) {
      Get.snackbar(
        'خطأ',
        'يجب اختيار خط السير',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      isLoading.value = true;

      if (!await isCustomerNameUnique(nameController.text.trim())) {
        Get.snackbar(
          'خطأ',
          'اسم العميل مستخدم بالفعل',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      final sessionService = Get.find<SessionService>();
      final userData = sessionService.currentUser;

      if (userData != null) {
        final selectedLine = lines.firstWhere(
          (line) => line.id == selectedLineId.value,
        );

        await _firestore.collection('customers').add({
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
          'تم إضافة العميل بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إضافة العميل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
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

  Future<void> importCustomers() async {
    try {
      if (selectedLineId.value == null) {
        showMessage(
          title: 'خطأ',
          message: 'يجب اختيار خط السير أولاً',
          success: false,
        );
        return;
      }

      final pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (pickerResult != null) {
        isLoading.value = true;
        final path = pickerResult.files.single.path!;
        final extension = pickerResult.files.single.extension!.toLowerCase();
        List<CustomerData> customers = [];

        if (extension == 'xlsx') {
          customers = await _readExcelFile(path);
        } else if (extension == 'csv') {
          customers = await _readCsvFile(path);
        }

        if (customers.isEmpty) {
          showMessage(
            title: 'خطأ',
            message: 'لم يتم العثور على بيانات في الملف',
            success: false,
          );
          return;
        }

        // إنشاء controller للمراجعة
        final reviewController = ReviewCustomersController(customers);
        Get.put(reviewController);

        // عرض صفحة المراجعة
        final dialogResult = await Get.to<List<CustomerData>>(
          () => ReviewCustomersView(
            customers: customers,
            onSave: (selectedCustomers) {
              Get.back(result: selectedCustomers);
            },
          ),
          binding: ReviewCustomersBinding(),
          arguments: {
            'customers': customers,
            'onSave': (List<CustomerData> selectedCustomers) {
              Get.back(result: selectedCustomers);
            },
          },
        );

        if (dialogResult != null && dialogResult.isNotEmpty) {
          // إضافة العملاء المحددين
          final selectedLine = lines.firstWhere(
            (line) => line.id == selectedLineId.value,
          );

          final batch = _firestore.batch();
          final sessionService = Get.find<SessionService>();
          final userData = sessionService.currentUser;

          for (var customer in dialogResult) {
            final docRef = _firestore.collection('customers').doc();
            batch.set(docRef, {
              'name': customer.name.trim(),
              'phone': customer.phone?.trim() ?? '',
              'nickname': customer.nickname?.trim() ?? '',
              'ovenType': customer.ovenType?.trim() ?? '',
              'discount': 0,
              'line': {
                'id': selectedLine.id,
                'name': selectedLine['name'],
              },
              'createdAt': FieldValue.serverTimestamp(),
              'createdBy': {
                'uid': userData?['uid'],
                'name': userData?['name'],
                'role': userData?['role'],
              },
            });
          }

          await batch.commit();

          showMessage(
            title: 'تم بنجاح',
            message: 'تم إضافة ${dialogResult.length} عميل بنجاح',
            success: true,
          );
        }
      }
    } catch (e) {
      showMessage(
        title: 'خطأ',
        message: 'حدث خطأ أثناء استيراد البيانات',
        success: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CustomerData>> _readExcelFile(String path) async {
    final bytes = File(path).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first]!;

    return sheet.rows.skip(1).map((row) {
      return CustomerData(
        name: row[0]?.value?.toString() ?? '',
        phone: row[1]?.value?.toString(),
        nickname: row[2]?.value?.toString(),
        ovenType: row[3]?.value?.toString(),
      );
    }).toList();
  }

  Future<List<CustomerData>> _readCsvFile(String path) async {
    final bytes = File(path).readAsBytesSync();
    final csv = const CsvToListConverter().convert(String.fromCharCodes(bytes));

    return csv.skip(1).map((row) {
      return CustomerData(
        name: row[0]?.toString() ?? '',
        phone: row[1]?.toString(),
        nickname: row[2]?.toString(),
        ovenType: row[3]?.toString(),
      );
    }).toList();
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
