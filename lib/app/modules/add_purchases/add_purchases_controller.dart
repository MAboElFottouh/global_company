import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_service.dart';
import 'package:flutter/material.dart';

class AddPurchasesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final products = <DocumentSnapshot>[].obs;
  final selectedItems = <Map<String, dynamic>>[].obs;

  // متغيرات مؤقتة للإدخال الحالي
  final selectedProduct = Rxn<DocumentSnapshot>();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  // متغير لتخزين آخر سعر شراء
  final lastPurchasePrice = RxnDouble();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final QuerySnapshot result =
          await _firestore.collection('products').orderBy('name').get();
      products.value = result.docs;
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // دالة للحصول على آخر سعر شراء للمنتج
  Future<void> getLastPurchasePrice(String productId) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('purchases')
          .orderBy('createdAt', descending: true)
          .get();

      if (result.docs.isNotEmpty) {
        for (var doc in result.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final items = data['items'] as List;
          final productItem = items.firstWhere(
            (item) => item['productId'] == productId,
            orElse: () => null,
          );

          if (productItem != null) {
            lastPurchasePrice.value = productItem['price'].toDouble();
            return;
          }
        }
      }

      // إذا لم يتم العثور على سعر سابق
      lastPurchasePrice.value = null;
    } catch (e) {
      print('Error getting last purchase price: $e');
      lastPurchasePrice.value = null;
    }
  }

  // تعديل onChanged الخاص بـ DropdownButtonFormField
  void onProductSelected(DocumentSnapshot? value) {
    selectedProduct.value = value;
    if (value != null) {
      getLastPurchasePrice(value.id);
    } else {
      lastPurchasePrice.value = null;
    }
  }

  void addItemToInvoice() {
    if (selectedProduct.value == null ||
        quantityController.text.isEmpty ||
        priceController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إكمال بيانات المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    final productData = selectedProduct.value!.data() as Map<String, dynamic>;
    final quantity = int.parse(quantityController.text);
    final price = double.parse(priceController.text);

    selectedItems.add({
      'product': selectedProduct.value,
      'productData': productData,
      'quantity': quantity,
      'price': price,
      'total': quantity * price,
    });

    // إعادة تعيين الحقول للمنتج التالي
    selectedProduct.value = null;
    quantityController.clear();
    priceController.clear();
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
  }

  double get totalAmount {
    return selectedItems.fold(0, (sum, item) => sum + item['total']);
  }

  Future<String> _getNextInvoiceNumber() async {
    final QuerySnapshot result = await _firestore
        .collection('purchases')
        .orderBy('invoiceNumber', descending: true)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return '1';
    }

    final lastNumber = int.parse(result.docs.first['invoiceNumber'].toString());
    return (lastNumber + 1).toString();
  }

  Future<void> savePurchase() async {
    if (selectedItems.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إضافة منتج واحد على الأقل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      isLoading.value = true;
      final batch = _firestore.batch();
      final purchaseDoc = _firestore.collection('purchases').doc();
      final sessionService = Get.find<SessionService>();
      final userData = sessionService.currentUser;
      final invoiceNumber = await _getNextInvoiceNumber();

      final purchaseData = {
        'invoiceNumber': invoiceNumber,
        'total': totalAmount,
        'items': selectedItems.map((item) {
          return {
            'productId': item['product'].id,
            'productName': item['productData']['name'],
            'quantity': item['quantity'],
            'price': item['price'],
            'total': item['total'],
          };
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': {
          'uid': userData?['uid'],
          'name': userData?['name'],
          'role': userData?['role'],
        },
      };

      batch.set(purchaseDoc, purchaseData);

      // تحديث المخزون لكل منتج
      for (var item in selectedItems) {
        final productDoc = item['product'].reference;
        final currentStock = item['productData']['stock'] ?? 0;
        final newStock = currentStock + item['quantity'];
        batch.update(productDoc, {'stock': newStock});
      }

      await batch.commit();

      // إعادة تعيين القائمة
      selectedItems.clear();

      Get.snackbar(
        'تم بنجاح',
        'تم إضافة الفاتورة رقم: $invoiceNumber',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إضافة المشتريات',
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
    quantityController.dispose();
    priceController.dispose();
    super.onClose();
  }
}
