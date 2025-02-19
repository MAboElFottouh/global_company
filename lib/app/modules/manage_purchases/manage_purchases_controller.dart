import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_service.dart';
import 'package:flutter/material.dart';

class ManagePurchasesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = Get.find<SessionService>();
  final isLoading = false.obs;
  final purchases = <DocumentSnapshot>[].obs;
  final searchController = TextEditingController();
  final filteredPurchases = <DocumentSnapshot>[].obs;

  // إضافة متغير للتحقق من صلاحيات المستخدم
  bool get isAdmin => _sessionService.currentUser?['role'] == 'admin';

  @override
  void onInit() {
    super.onInit();
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    try {
      isLoading.value = true;
      final QuerySnapshot result = await _firestore
          .collection('purchases')
          .orderBy('createdAt', descending: true)
          .get();

      purchases.value = result.docs;
      filteredPurchases.value = result.docs;
    } catch (e) {
      print('Error loading purchases: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterPurchases(String query) {
    if (query.isEmpty) {
      filteredPurchases.value = purchases;
      return;
    }

    filteredPurchases.value = purchases.where((purchase) {
      final data = purchase.data() as Map<String, dynamic>;
      final invoiceNumber = data['invoiceNumber'].toString();
      final items = (data['items'] as List);

      // البحث في رقم الفاتورة
      if (invoiceNumber.contains(query)) {
        return true;
      }

      // البحث في أسماء المنتجات
      return items.any((item) => item['productName']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()));
    }).toList();
  }

  Future<void> deletePurchase(String purchaseId) async {
    try {
      isLoading.value = true;

      // الحصول على بيانات الفاتورة قبل حذفها
      final purchaseDoc =
          await _firestore.collection('purchases').doc(purchaseId).get();
      final purchaseData = purchaseDoc.data() as Map<String, dynamic>;
      final items = purchaseData['items'] as List;

      final batch = _firestore.batch();

      // تحديث المخزون لكل منتج (طرح الكميات)
      for (var item in items) {
        final productDoc =
            _firestore.collection('products').doc(item['productId']);
        final productSnapshot = await productDoc.get();
        final currentStock =
            (productSnapshot.data() as Map<String, dynamic>)['stock'] ?? 0;
        final newStock = currentStock - item['quantity'];
        batch.update(productDoc, {'stock': newStock});
      }

      // حذف الفاتورة
      batch.delete(purchaseDoc.reference);

      await batch.commit();
      await loadPurchases(); // إعادة تحميل القائمة

      Get.snackbar(
        'تم بنجاح',
        'تم حذف الفاتورة وتحديث المخزون',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
