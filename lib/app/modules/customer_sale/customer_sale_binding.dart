import 'package:get/get.dart';
import 'customer_sale_controller.dart';
import 'package:flutter/material.dart';

class CustomerSaleBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;

    // التحقق من وجود جميع البيانات المطلوبة
    if (args['customerId'] == null ||
        args['customerName'] == null ||
        args['delegateId'] == null ||
        args['delegateName'] == null) {
      print('Error: Missing required arguments');
      print('Arguments received: $args');
      Get.back();
      Get.snackbar(
        'خطأ',
        'بيانات غير مكتملة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    Get.lazyPut<CustomerSaleController>(
      () => CustomerSaleController(
        customerId: args['customerId'] as String,
        customerName: args['customerName'] as String,
        delegateId: args['delegateId'] as String,
        delegateName: args['delegateName'] as String,
      ),
    );
  }
}
