import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ReturnDetailsController extends GetxController {
  final products = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  late final Map<String, dynamic> invoiceData;

  @override
  void onInit() {
    super.onInit();
    loadInvoiceDetails();
  }

  void loadInvoiceDetails() {
    try {
      isLoading.value = true;

      invoiceData = Get.arguments['invoice'] as Map<String, dynamic>;

      if (invoiceData == null) {
        Get.snackbar('خطأ', 'لا توجد بيانات للفاتورة');
        return;
      }

      final productsList =
          (invoiceData['products'] as List<dynamic>).map((product) {
        return {
          ...Map<String, dynamic>.from(product),
          'originalQuantity': product['quantity'],
          'returnedQuantity': 0,
        };
      }).toList();

      products.value = productsList;
    } catch (e) {
      print('Error in loadInvoiceDetails: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل تفاصيل الفاتورة');
    } finally {
      isLoading.value = false;
    }
  }

  void increaseReturnedQuantity(int index) {
    final updatedProducts = List<Map<String, dynamic>>.from(products);
    final product = Map<String, dynamic>.from(updatedProducts[index]);

    if (product['returnedQuantity'] < product['originalQuantity']) {
      product['returnedQuantity']++;
      updatedProducts[index] = product;
      products.value = updatedProducts;
    }
  }

  bool get hasReturns {
    return products.any((product) => product['returnedQuantity'] > 0);
  }

  Future<void> confirmReturns() async {
    try {
      final returnedProducts =
          products.where((p) => p['returnedQuantity'] > 0).toList();

      if (returnedProducts.isEmpty) {
        Get.snackbar('تنبيه', 'لم يتم اختيار أي منتجات للإرجاع');
        return;
      }

      // هنا يمكنك إضافة المنطق الخاص بحفظ المرتجع في قاعدة البيانات

      Get.snackbar('نجاح', 'تم تسجيل المرتجع بنجاح');
      Get.back();
    } catch (e) {
      print('Error in confirmReturns: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تسجيل المرتجع');
    }
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('yyyy/MM/dd - HH:mm').format(date);
  }

  void showReturnDialog(int index) {
    final product = products[index];
    final maxQuantity = product['quantity'] as int;

    Get.dialog(
      AlertDialog(
        title: const Text('تحديد كمية المرتجع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المنتج: ${product['productName']}'),
            const SizedBox(height: 16),
            Text('الكمية المتاحة للإرجاع: $maxQuantity'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'كمية المرتجع',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final returnQty = int.tryParse(value) ?? 0;
                if (returnQty <= maxQuantity && returnQty >= 0) {
                  final updatedProducts = [...products];
                  updatedProducts[index] = {
                    ...updatedProducts[index],
                    'returnedQuantity': returnQty,
                  };
                  products.value = updatedProducts;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
