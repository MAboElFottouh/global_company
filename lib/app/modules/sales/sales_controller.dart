import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> sales = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allSales = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedDate = ''.obs;
  final searchType = 'customerName'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSales();
  }

  Future<Map<String, dynamic>?> getDelegateInfo(String delegateId) async {
    try {
      final delegateDoc =
          await _firestore.collection('users').doc(delegateId).get();
      if (delegateDoc.exists) {
        final data = delegateDoc.data()!;
        return {
          'name': data['name'] ?? 'غير معروف',
          'phone': data['phone'] ?? '',
        };
      }
    } catch (e) {
      print('Error getting delegate info: $e');
    }
    return null;
  }

  Future<void> loadSales() async {
    try {
      isLoading.value = true;

      var query = _firestore
          .collection('invoices')
          .orderBy('createdAt', descending: true);

      if (searchQuery.value.isNotEmpty) {
        query = query
            .where('delegateName', isGreaterThanOrEqualTo: searchQuery.value)
            .where('delegateName',
                isLessThanOrEqualTo: searchQuery.value + '\uf8ff');
      }

      if (selectedDate.value.isNotEmpty) {
        DateTime selected = DateTime.parse(selectedDate.value);
        DateTime endOfDay =
            DateTime(selected.year, selected.month, selected.day, 23, 59, 59);

        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(selected),
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
      }

      final QuerySnapshot invoicesSnapshot = await query.get();

      // جمع كل معرفات المندوبين
      final delegateIds = invoicesSnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['delegateId'] as String?)
          .where((id) => id != null)
          .toSet();

      // جلب معلومات المندوبين مرة واحدة
      final delegatesInfo = <String, Map<String, dynamic>>{};
      for (final delegateId in delegateIds) {
        final delegateData = await getDelegateInfo(delegateId!);
        if (delegateData != null) {
          delegatesInfo[delegateId] = delegateData;
        }
      }

      // تحميل معلومات العملاء مسبقاً
      final customersSnapshot =
          await FirebaseFirestore.instance.collection('customers').get();

      final customersInfo = Map.fromEntries(
        customersSnapshot.docs.map((doc) => MapEntry(doc.id, doc.data())),
      );

      sales.value = await Future.wait(invoicesSnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final delegateId = data['delegateId'];
        final customerId = data['customerId'];
        final delegateInfo = delegatesInfo[delegateId];
        final customerInfo = customersInfo[customerId];

        // استخراج معلومات الخط
        final lineInfo = customerInfo?['line'] as Map<String, dynamic>?;

        // دالة مساعدة للتعامل مع القيم الرقمية
        num safeNumber(dynamic value) {
          if (value == null) return 0;
          if (value is num) return value;
          if (value is String) {
            return num.tryParse(value) ?? 0;
          }
          return 0;
        }

        // معالجة المنتجات
        List<Map<String, dynamic>> processProducts() {
          final productsList = data['products'] as List<dynamic>? ?? [];
          return productsList.map((product) {
            return {
              'productId': product['productId'] ?? '',
              'productName': product['productName'] ?? '',
              'quantity': safeNumber(product['quantity']),
              'price': safeNumber(product['price']),
              'originalPrice': safeNumber(product['originalPrice']),
              'discount': safeNumber(product['discount']),
              'totalAmount': safeNumber(product['totalAmount']),
            };
          }).toList();
        }

        return {
          'customerName': data['customerName'] ?? 'غير معروف',
          'customerId': customerId ?? '',
          'createdAt': data['createdAt'] ?? Timestamp.now(),
          'total': safeNumber(data['totalAmount']),
          'paidAmount': safeNumber(data['paidAmount']),
          'remainingAmount': safeNumber(data['remainingAmount']),
          'previousBalance': safeNumber(data['previousBalance']),
          'paymentType': data['paymentType'] ?? '',
          'products': processProducts(),
          'delegateId': delegateId,
          'delegateName': delegateInfo?['name'] ?? 'غير معروف',
          'delegatePhone': delegateInfo?['phone'] ?? '',
          // إضافة معلومات الخط
          'lineName': lineInfo?['name'] ?? 'غير محدد',
          'lineNickname': customerInfo?['nickname'] ?? '',
          'ovenType': customerInfo?['ovenType'] ?? '',
          'customerPhone': customerInfo?['phone'] ?? '',
        };
      }).toList());

      allSales.value = sales.value;
    } catch (e) {
      print('Error loading invoices: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الفواتير',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool hasInvoicesForDate(DateTime date) {
    return allSales.any((sale) {
      final saleDate = (sale['createdAt'] as Timestamp).toDate();
      return saleDate.year == date.year &&
          saleDate.month == date.month &&
          saleDate.day == date.day;
    });
  }

  void filterByDate(DateTime selectedDate) {
    sales.value = allSales.where((sale) {
      final saleDate = (sale['createdAt'] as Timestamp).toDate();
      return saleDate.year == selectedDate.year &&
          saleDate.month == selectedDate.month &&
          saleDate.day == selectedDate.day;
    }).toList();
  }

  void updateSearchQuery(String query) {
    if (query.isEmpty) {
      sales.value = allSales;
      return;
    }

    switch (searchType.value) {
      case 'customerName':
        sales.value = allSales
            .where((sale) => sale['customerName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        break;
      case 'delegateName':
        sales.value = allSales
            .where((sale) => sale['delegateName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        break;
      case 'lineName':
        sales.value = allSales
            .where((sale) => sale['lineName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        break;
    }
  }

  void updateSelectedDate(String date) {
    selectedDate.value = date;
    loadSales();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedDate.value = '';
    loadSales();
  }
}
