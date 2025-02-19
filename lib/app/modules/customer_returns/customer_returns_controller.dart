import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

      // حساب تاريخ قبل أسبوع
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      final invoicesRef = FirebaseFirestore.instance.collection('invoices');
      final snapshot = await invoicesRef
          .where('customerId', isEqualTo: customerId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
          .get();

      // نقوم بالترتيب بعد جلب البيانات
      final sortedDocs = snapshot.docs;
      sortedDocs.sort((a, b) {
        final aTime =
            (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
        final bTime =
            (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
        return bTime.compareTo(aTime); // ترتيب تنازلي (الأحدث أولاً)
      });

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
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل الفواتير');
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('yyyy/MM/dd - HH:mm').format(date);
  }

  void showInvoiceDetails(QueryDocumentSnapshot invoice) {
    // سيتم تنفيذ هذه الوظيفة لاحقاً
    Get.snackbar('قريباً', 'سيتم إضافة تفاصيل الفاتورة قريباً');
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
