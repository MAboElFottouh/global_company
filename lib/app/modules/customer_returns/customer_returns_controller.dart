import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

class CustomerReturnsController extends GetxController {
  final customerId = Get.arguments['customerId'];
  final customerName = Get.arguments['customerName'];

  final recentInvoices = <QueryDocumentSnapshot>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('ar');
    loadRecentInvoices();
  }

  Future<void> loadRecentInvoices() async {
    try {
      isLoading.value = true;

      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      final invoicesRef = FirebaseFirestore.instance.collection('invoices');
      final snapshot = await invoicesRef
          .where('customerId', isEqualTo: customerId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
          .get();

      final sortedDocs = snapshot.docs;
      sortedDocs.sort((a, b) {
        final aTime =
            (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
        final bTime =
            (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      // تحميل أسماء المندوبين مسبقاً
      for (var doc in sortedDocs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['delegateId'] != null) {
          final delegateName = await getDelegateName(data['delegateId']);
          data['delegateName'] = delegateName;
        }
      }

      recentInvoices.value = sortedDocs;

      // للتشخيص
      print('Found ${sortedDocs.length} invoices');
      print('Customer ID: $customerId');
      for (var doc in sortedDocs) {
        print(
            'Invoice date: ${(doc.data() as Map<String, dynamic>)['createdAt']}');
      }
    } catch (e, stackTrace) {
      print('Error loading invoices: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الفواتير',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('yyyy/MM/dd - HH:mm').format(date);
  }

  void showInvoiceDetails(Map<String, dynamic> invoiceData) {
    try {
      if (invoiceData == null) {
        Get.snackbar(
          'خطأ',
          'لا توجد بيانات للفاتورة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('Invoice Data: $invoiceData');
      print('Products: ${invoiceData['products']}');

      if (invoiceData['products'] == null ||
          (invoiceData['products'] as List).isEmpty) {
        Get.snackbar(
          'خطأ',
          'لا توجد منتجات في هذه الفاتورة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Map<String, dynamic> formattedInvoice = {
        'products': invoiceData['products'],
        'createdAt': invoiceData['createdAt'],
        'delegateId': invoiceData['delegateId'] ?? '',
        'delegateName': invoiceData['delegateName'] ?? 'غير معروف',
        'totalDue': invoiceData['totalDue'] ?? 0.0,
        'customerName': customerName,
        'customerId': customerId,
      };

      Get.toNamed(
        '/return-details',
        arguments: {'invoice': formattedInvoice},
        preventDuplicates: true,
      );
    } catch (e, stackTrace) {
      print('Error in showInvoiceDetails: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء فتح تفاصيل الفاتورة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<String> getDelegateName(String delegateId) async {
    try {
      final delegateDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(delegateId)
          .get();

      if (delegateDoc.exists) {
        return delegateDoc.data()?['name'] ?? 'غير معروف';
      }
      return 'غير معروف';
    } catch (e) {
      print('Error getting delegate name: $e');
      return 'غير معروف';
    }
  }
}
