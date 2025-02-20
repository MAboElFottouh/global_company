import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ReturnDetailsController extends GetxController {
  final products = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  late final Map<String, dynamic> invoiceData;
  final totalReturnAmount = 0.0.obs;
  final customerDelayedBalance = 0.0.obs;
  final isLoadingCustomerData = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvoiceDetails();
    loadCustomerBalance();
  }

  void loadInvoiceDetails() {
    try {
      isLoading.value = true;

      if (Get.arguments == null || !Get.arguments.containsKey('invoice')) {
        Get.snackbar(
          'خطأ',
          'لا توجد بيانات للفاتورة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      invoiceData = Get.arguments['invoice'] as Map<String, dynamic>;

      // طباعة البيانات للتشخيص
      print('Received invoice data: $invoiceData');

      if (invoiceData['products'] == null) {
        Get.snackbar(
          'خطأ',
          'بيانات الفاتورة غير مكتملة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final productsList =
          (invoiceData['products'] as List<dynamic>).map((product) {
        // التأكد من أن جميع القيم موجودة وتحويلها إلى النوع المناسب
        return {
          'productName': product['productName'] ?? 'منتج غير معروف',
          'price': (product['price'] ?? 0.0).toDouble(),
          'quantity': product['quantity'] ?? 0,
          'discount': product['discount']?.toDouble() ?? 0.0,
          'originalQuantity': product['quantity'] ?? 0,
          'returnedQuantity': 0,
        };
      }).toList();

      products.value = productsList;
    } catch (e, stackTrace) {
      print('Error in loadInvoiceDetails: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل تفاصيل الفاتورة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomerBalance() async {
    try {
      if (invoiceData == null || !invoiceData.containsKey('customerId')) {
        print('No customer ID found in invoice data');
        return;
      }

      isLoadingCustomerData.value = true;
      final customerId = invoiceData['customerId'];

      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .get();

      if (customerDoc.exists) {
        customerDelayedBalance.value =
            customerDoc.data()?['delayedBalance']?.toDouble() ?? 0.0;
      }
    } catch (e) {
      print('Error loading customer balance: $e');
      Get.snackbar(
        'تنبيه',
        'لم نتمكن من تحميل بيانات مديونية العميل',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCustomerData.value = false;
    }
  }

  void decreaseReturnedQuantity(int index) {
    final updatedProducts = List<Map<String, dynamic>>.from(products);
    final product = Map<String, dynamic>.from(updatedProducts[index]);

    if (product['returnedQuantity'] > 0) {
      product['returnedQuantity']--;
      updatedProducts[index] = product;
      products.value = updatedProducts;
      calculateTotalReturn();
    }
  }

  void increaseReturnedQuantity(int index) {
    final updatedProducts = List<Map<String, dynamic>>.from(products);
    final product = Map<String, dynamic>.from(updatedProducts[index]);

    if (product['returnedQuantity'] < product['originalQuantity']) {
      product['returnedQuantity']++;
      updatedProducts[index] = product;
      products.value = updatedProducts;
      calculateTotalReturn();
    }
  }

  void calculateTotalReturn() {
    double total = 0.0;
    for (var product in products) {
      if (product['returnedQuantity'] > 0) {
        double price = product['price'].toDouble();
        int returnedQty = product['returnedQuantity'];
        double discount = product['discount']?.toDouble() ?? 0.0;

        double itemTotal = price * returnedQty;
        if (discount > 0) {
          itemTotal = itemTotal - (itemTotal * (discount / 100));
        }
        total += itemTotal;
      }
    }
    totalReturnAmount.value = total;
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

      final returnAmount = totalReturnAmount.value;
      final delegateId = invoiceData['delegateId'];

      // 1. حفظ عملية المرتجع في تيبول returns
      await saveReturnRecord(returnedProducts, returnAmount);

      // 2. تحديث مخزون المندوب في delegate_deliveries
      await updateDelegateInventory(delegateId, returnedProducts);

      // 3. تحديث مديونية العميل وحساب المندوب
      await updateBalances(delegateId, returnAmount);

      // 4. تحديث كميات المنتجات في الفاتورة الأصلية
      await updateInvoiceQuantities(returnedProducts);

      Get.snackbar('نجاح', 'تم تسجيل المرتجع بنجاح');
      Get.back();
    } catch (e) {
      print('Error in confirmReturns: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تسجيل المرتجع');
    }
  }

  Future<void> saveReturnRecord(
      List<Map<String, dynamic>> returnedProducts, double returnAmount) async {
    try {
      final returnsRef = FirebaseFirestore.instance.collection('returns');

      // تجهيز بيانات المرتجع
      final returnData = {
        'customerId': invoiceData['customerId'],
        'customerName': invoiceData['customerName'],
        'delegateId': invoiceData['delegateId'],
        'delegateName': invoiceData['delegateName'],
        'originalInvoiceDate': invoiceData['createdAt'],
        'returnDate': Timestamp.now(),
        'totalAmount': returnAmount,
        'products': returnedProducts
            .map((product) => {
                  'productId': product['productId'],
                  'productName': product['productName'],
                  'price': product['price'],
                  'quantity': product['returnedQuantity'],
                  'discount': product['discount'] ?? 0.0,
                  'total': calculateProductTotal(
                    product['price'],
                    product['returnedQuantity'],
                    product['discount'] ?? 0.0,
                  ),
                })
            .toList(),
        'status': 'completed', // يمكن إضافة حالات أخرى مثل pending, cancelled
        'notes': '', // يمكن إضافة ملاحظات إذا كان هناك حاجة
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        // معلومات إضافية عن الفاتورة الأصلية
        'originalInvoiceId': invoiceData['id'] ?? '',
        'originalInvoiceTotalAmount': invoiceData['totalAmount'] ?? 0.0,
        // معلومات عن التعديلات المالية
        'deductedFromCustomerBalance':
            min(customerDelayedBalance.value, returnAmount),
        'deductedFromDelegateBalance':
            max(0.0, returnAmount - customerDelayedBalance.value),
      };

      // حفظ سجل المرتجع
      await returnsRef.add(returnData);
    } catch (e) {
      print('Error saving return record: $e');
      throw e;
    }
  }

  double calculateProductTotal(double price, int quantity, double discount) {
    double total = price * quantity;
    if (discount > 0) {
      total = total - (total * (discount / 100));
    }
    return total;
  }

  Future<void> updateDelegateInventory(
      String delegateId, List<Map<String, dynamic>> returnedProducts) async {
    try {
      final delegateDeliveriesRef =
          FirebaseFirestore.instance.collection('delegate_deliveries');

      // البحث عن سجل المندوب
      final querySnapshot = await delegateDeliveriesRef
          .where('delegateId', isEqualTo: delegateId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // إنشاء سجل جديد للمندوب
        await delegateDeliveriesRef.add({
          'delegateId': delegateId,
          'delegateName': invoiceData['delegateName'],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'products': returnedProducts
              .map((product) => {
                    'productId': product['productId'],
                    'productName': product['productName'],
                    'price': product['price'],
                    'quantity': product['returnedQuantity'],
                  })
              .toList(),
        });
      } else {
        // تحديث السجل الموجود
        final doc = querySnapshot.docs.first;
        final existingProducts =
            List<Map<String, dynamic>>.from(doc['products'] ?? []);

        // تحديث الكميات للمنتجات الموجودة أو إضافة منتجات جديدة
        for (var returnedProduct in returnedProducts) {
          final existingProductIndex = existingProducts.indexWhere(
              (p) => p['productId'] == returnedProduct['productId']);

          if (existingProductIndex >= 0) {
            // تحديث كمية المنتج الموجود
            existingProducts[existingProductIndex]['quantity'] =
                (existingProducts[existingProductIndex]['quantity'] ?? 0) +
                    returnedProduct['returnedQuantity'];
          } else {
            // إضافة منتج جديد
            existingProducts.add({
              'productId': returnedProduct['productId'],
              'productName': returnedProduct['productName'],
              'price': returnedProduct['price'],
              'quantity': returnedProduct['returnedQuantity'],
            });
          }
        }

        await doc.reference.update({
          'products': existingProducts,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error updating delegate inventory: $e');
      throw e;
    }
  }

  Future<void> updateBalances(String delegateId, double returnAmount) async {
    try {
      final customerId = invoiceData['customerId'];

      // تحديث مديونية العميل
      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .get();

      double remainingAmount = returnAmount;
      double customerDelayedBalance =
          customerDoc.data()?['delayedBalance']?.toDouble() ?? 0.0;

      if (customerDelayedBalance > 0) {
        // خصم من مديونية العميل أولاً
        double amountToDeduct = min(customerDelayedBalance, returnAmount);
        remainingAmount -= amountToDeduct;
        customerDelayedBalance -= amountToDeduct;

        await customerDoc.reference.update({
          'delayedBalance': customerDelayedBalance,
        });
      }

      if (remainingAmount > 0) {
        // خصم المبلغ المتبقي من رصيد المندوب
        final delegateDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(delegateId)
            .get();

        double delegateBalance =
            delegateDoc.data()?['balance']?.toDouble() ?? 0.0;
        delegateBalance -= remainingAmount;

        await delegateDoc.reference.update({
          'balance': delegateBalance,
        });
      }
    } catch (e) {
      print('Error updating balances: $e');
      throw e;
    }
  }

  Future<void> updateInvoiceQuantities(
      List<Map<String, dynamic>> returnedProducts) async {
    try {
      // الحصول على مرجع الفاتورة
      final invoicesRef = FirebaseFirestore.instance.collection('invoices');
      final querySnapshot = await invoicesRef
          .where('customerId', isEqualTo: invoiceData['customerId'])
          .where('createdAt', isEqualTo: invoiceData['createdAt'])
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('لم يتم العثور على الفاتورة');
      }

      final invoiceDoc = querySnapshot.docs.first;
      final invoiceProducts =
          List<Map<String, dynamic>>.from(invoiceDoc['products'] ?? []);

      // تحديث كميات المنتجات
      for (var returnedProduct in returnedProducts) {
        final productIndex = invoiceProducts
            .indexWhere((p) => p['productId'] == returnedProduct['productId']);

        if (productIndex >= 0) {
          // تحديث الكمية في الفاتورة
          final currentQuantity =
              invoiceProducts[productIndex]['quantity'] as int;
          final returnedQuantity = returnedProduct['returnedQuantity'] as int;

          invoiceProducts[productIndex]['quantity'] =
              currentQuantity - returnedQuantity;

          // إذا كانت الكمية صفر، يمكنك إما إزالة المنتج أو تركه بكمية صفر
          // في هذه الحالة سنتركه بكمية صفر
        }
      }

      // تحديث إجمالي الفاتورة
      double newTotalAmount = 0.0;
      for (var product in invoiceProducts) {
        final price = (product['price'] ?? 0.0).toDouble();
        final quantity = product['quantity'] as int;
        final discount = (product['discount'] ?? 0.0).toDouble();

        double itemTotal = price * quantity;
        if (discount > 0) {
          itemTotal = itemTotal - (itemTotal * (discount / 100));
        }
        newTotalAmount += itemTotal;
      }

      // تحديث الفاتورة
      await invoiceDoc.reference.update({
        'products': invoiceProducts,
        'totalAmount': newTotalAmount,
        'totalDue': newTotalAmount,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating invoice quantities: $e');
      throw e;
    }
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('yyyy/MM/dd - HH:mm').format(date);
  }

  void showReturnDialog(int index) {
    final product = products[index];
    final maxQuantity = product['originalQuantity'] as int;
    final TextEditingController quantityController = TextEditingController();

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
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'كمية المرتجع',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              final returnQty = int.tryParse(quantityController.text) ?? 0;
              if (returnQty <= maxQuantity && returnQty >= 0) {
                final updatedProducts = [...products];
                updatedProducts[index] = {
                  ...updatedProducts[index],
                  'returnedQuantity': returnQty,
                };
                products.value = updatedProducts;
                calculateTotalReturn();
                Get.back();
              } else {
                Get.snackbar(
                  'خطأ',
                  'الكمية المدخلة غير صحيحة',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'تأكيد',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
