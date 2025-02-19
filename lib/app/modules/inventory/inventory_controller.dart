import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/session_service.dart';

class InventoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = Get.find<SessionService>();
  final isLoading = false.obs;
  final products = <DocumentSnapshot>[].obs;
  final searchController = TextEditingController();
  final filteredProducts = <DocumentSnapshot>[].obs;
  final lastPurchasePrices = <String, double>{}.obs;

  // إضافة متغير للتحقق من صلاحيات المستخدم
  bool get isAdmin => _sessionService.currentUser?['role'] == 'admin';

  // إضافة دالة لتعديل الكمية
  Future<void> updateStock(
      String productId, int currentStock, BuildContext context) async {
    final TextEditingController stockController = TextEditingController();
    stockController.text = currentStock.toString();

    await Get.dialog(
      AlertDialog(
        title: const Text('تعديل الكمية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final newStock = int.parse(stockController.text);
                await _firestore
                    .collection('products')
                    .doc(productId)
                    .update({'stock': newStock});

                Get.back();
                loadProducts(); // إعادة تحميل المنتجات

                Get.snackbar(
                  'تم بنجاح',
                  'تم تحديث الكمية',
                  backgroundColor: Colors.green[100],
                  colorText: Colors.green[900],
                );
              } catch (e) {
                Get.snackbar(
                  'خطأ',
                  'فشل تحديث الكمية',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[900],
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

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

      // ترتيب المنتجات حسب الكمية (من الأكثر للأقل)
      var sortedDocs = result.docs.toList()
        ..sort((a, b) {
          final stockA = (a.data() as Map<String, dynamic>)['stock'] ?? 0;
          final stockB = (b.data() as Map<String, dynamic>)['stock'] ?? 0;
          return stockB.compareTo(stockA); // ترتيب تنازلي
        });

      products.value = sortedDocs;
      filteredProducts.value = sortedDocs;

      // جلب آخر سعر شراء لكل منتج
      for (var product in result.docs) {
        getLastPurchasePrice(product.id);
      }
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

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
            lastPurchasePrices[productId] = productItem['price'].toDouble();
            return;
          }
        }
      }

      // إذا لم يتم العثور على سعر سابق
      lastPurchasePrices[productId] = 0;
    } catch (e) {
      print('Error getting last purchase price: $e');
      lastPurchasePrices[productId] = 0;
    }
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      // إعادة ترتيب المنتجات عند إلغاء البحث
      var sortedProducts = products.toList()
        ..sort((a, b) {
          final stockA = (a.data() as Map<String, dynamic>)['stock'] ?? 0;
          final stockB = (b.data() as Map<String, dynamic>)['stock'] ?? 0;
          return stockB.compareTo(stockA);
        });
      filteredProducts.value = sortedProducts;
      return;
    }

    // ترتيب نتائج البحث
    var filteredAndSorted = products.where((product) {
      final data = product.data() as Map<String, dynamic>;
      final name = data['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList()
      ..sort((a, b) {
        final stockA = (a.data() as Map<String, dynamic>)['stock'] ?? 0;
        final stockB = (b.data() as Map<String, dynamic>)['stock'] ?? 0;
        return stockB.compareTo(stockA);
      });

    filteredProducts.value = filteredAndSorted;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
