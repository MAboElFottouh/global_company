import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_controller.dart';

enum PaymentType { full, partial, delayed }

class InvoicePaymentController extends GetxController {
  final String customerId;
  final String customerName;
  final String delegateId;
  final double totalAmount;
  final List<Map<String, dynamic>> products;

  InvoicePaymentController({
    required this.customerId,
    required this.customerName,
    required this.delegateId,
    required this.totalAmount,
    required this.products,
  });

  final paymentType = PaymentType.full.obs;
  final paidAmountController = TextEditingController();
  final remainingAmount = 0.0.obs;
  final previousBalance = 0.0.obs;
  final totalBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    remainingAmount.value = totalAmount;
    loadCustomerBalance();
    calculateTotalBalance();
  }

  Future<void> loadCustomerBalance() async {
    try {
      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .get();

      if (customerDoc.exists) {
        final data = customerDoc.data()!;
        previousBalance.value = (data['delayedBalance'] ?? 0.0).toDouble();
        calculateTotalBalance();
      }
    } catch (e) {
      print('Error loading customer balance: $e');
    }
  }

  void calculateTotalBalance() {
    totalBalance.value = previousBalance.value + remainingAmount.value;
  }

  void calculateRemainingAmount() {
    final totalDue = totalAmount + previousBalance.value;

    if (paymentType.value == PaymentType.full) {
      remainingAmount.value = 0;
    } else if (paymentType.value == PaymentType.delayed) {
      remainingAmount.value = totalDue;
    } else {
      final paid = double.tryParse(paidAmountController.text) ?? 0;
      if (paid > totalDue) {
        paidAmountController.text = totalDue.toString();
        remainingAmount.value = 0;
        Get.snackbar(
          'تنبيه',
          'لا يمكن دفع مبلغ أكبر من المستحق',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
        );
      } else {
        remainingAmount.value = totalDue - paid;
      }
    }
    calculateTotalBalance();
  }

  Future<void> saveInvoice() async {
    try {
      if (customerId.isEmpty || delegateId.isEmpty) {
        throw Exception('بيانات غير مكتملة');
      }

      final batch = FirebaseFirestore.instance.batch();

      final totalDue = totalAmount + previousBalance.value;
      double paidAmount = 0.0;
      double delayedAmount = 0.0;

      if (paymentType.value == PaymentType.full) {
        paidAmount = totalDue;
        delayedAmount = 0;
      } else if (paymentType.value == PaymentType.partial) {
        final paid = double.tryParse(paidAmountController.text);
        if (paid == null || paid <= 0) {
          throw Exception('يرجى إدخال المبلغ المدفوع');
        }
        paidAmount = paid;
        delayedAmount = remainingAmount.value;
      } else {
        paidAmount = 0;
        delayedAmount = totalDue;
      }

      // تحديث كمية المنتجات عند المندوب
      final QuerySnapshot delegateDeliverySnapshot = await FirebaseFirestore
          .instance
          .collection('delegate_deliveries')
          .where('delegateId', isEqualTo: delegateId)
          .limit(1)
          .get();

      if (delegateDeliverySnapshot.docs.isEmpty) {
        throw Exception('لم يتم العثور على منتجات المندوب');
      }

      final delegateDeliveryDoc = delegateDeliverySnapshot.docs.first;
      final Map<String, dynamic> deliveryData =
          delegateDeliveryDoc.data() as Map<String, dynamic>;
      final List<dynamic> currentProducts = deliveryData['products'] ?? [];

      // تحويل المنتجات الحالية إلى Map للسهولة في التحديث
      final Map<String, Map<String, dynamic>> productMap = {};
      for (var product in currentProducts) {
        productMap[product['productId']] = Map<String, dynamic>.from(product);
      }

      // تحديث الكميات
      for (var soldProduct in products) {
        final productId = soldProduct['productId'];
        if (productMap.containsKey(productId)) {
          final currentQuantity = productMap[productId]!['quantity'] as int;
          final soldQuantity = soldProduct['quantity'] as int;

          if (currentQuantity < soldQuantity) {
            throw Exception(
                'الكمية المطلوبة غير متوفرة للمنتج: ${soldProduct['productName']}');
          }

          productMap[productId]!['quantity'] = currentQuantity - soldQuantity;
        }
      }

      // تحديث المنتجات في قاعدة البيانات
      batch.update(delegateDeliveryDoc.reference, {
        'products': productMap.values.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث رصيد العميل
      final customerRef =
          FirebaseFirestore.instance.collection('customers').doc(customerId);
      Map<String, dynamic> customerUpdate = {
        'delayedBalance': delayedAmount,
        'hasDelayedPayments': delayedAmount > 0,
      };
      batch.update(customerRef, customerUpdate);

      // تحديث رصيد المندوب
      final delegateRef =
          FirebaseFirestore.instance.collection('users').doc(delegateId);
      Map<String, dynamic> delegateUpdate = {
        'balance': FieldValue.increment(paidAmount),
        'totalSales': FieldValue.increment(totalAmount),
      };
      batch.update(delegateRef, delegateUpdate);

      // إنشاء الفاتورة
      final invoiceRef =
          FirebaseFirestore.instance.collection('invoices').doc();
      batch.set(invoiceRef, {
        'customerId': customerId,
        'customerName': customerName,
        'delegateId': delegateId,
        'totalAmount': totalAmount,
        'previousBalance': previousBalance.value,
        'totalDue': totalDue,
        'paidAmount': paidAmount,
        'remainingAmount': delayedAmount,
        'paymentType': paymentType.value.toString(),
        'products': products,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // تحديث البيانات في الصفحة الرئيسية
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.loadDelegateInfo();
      }

      // الرجوع مرتين للعودة إلى صفحة العملاء
      Get.back();
      Get.back();

      Get.snackbar(
        'تم بنجاح',
        'تم إصدار الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      print('Error saving invoice: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        e.toString().contains('Exception')
            ? e.toString().replaceAll('Exception: ', '')
            : 'فشل إصدار الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  void onClose() {
    paidAmountController.dispose();
    super.onClose();
  }
}
