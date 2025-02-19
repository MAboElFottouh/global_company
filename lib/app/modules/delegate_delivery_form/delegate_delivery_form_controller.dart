import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/selected_product.dart';
import 'views/product_selection_view.dart';
import 'package:flutter/material.dart';

class DelegateDeliveryFormController extends GetxController {
  final String delegateId;
  final String delegateName;
  final double currentBalance;
  final selectedProducts = <SelectedProduct>[].obs;
  final totalQuantity = 0.obs;
  final totalAmount = 0.0.obs;
  final scrollToIndex = (-1).obs;
  final focusQuantityIndex = (-1).obs;
  final isLoading = false.obs;

  DelegateDeliveryFormController({
    required this.delegateId,
    required this.delegateName,
    required this.currentBalance,
  });

  void updateQuantity(int index, int quantity) {
    if (quantity <= selectedProducts[index].availableQuantity) {
      // تحديث كمية المنتج
      final updatedProduct = SelectedProduct(
        productId: selectedProducts[index].productId,
        productName: selectedProducts[index].productName,
        quantity: quantity,
        price: selectedProducts[index].price,
        availableQuantity: selectedProducts[index].availableQuantity,
      );
      selectedProducts[index] = updatedProduct;

      // إعادة حساب الإجماليات
      calculateTotals();
    }
  }

  void removeProduct(int index) {
    selectedProducts.removeAt(index);
    calculateTotals();
  }

  void calculateTotals() {
    int quantity = 0;
    double amount = 0.0;

    for (var product in selectedProducts) {
      quantity += product.quantity;
      amount += product.total;
    }

    totalQuantity.value = quantity;
    totalAmount.value = amount;
  }

  Future<void> showProductSelection() async {
    try {
      isLoading.value = true;

      final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
          .instance
          .collection('products')
          .where('stock', isGreaterThan: 0)
          .get();

      if (result.docs.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'لا توجد منتجات متاحة في المخزن',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
        );
        return;
      }

      // طباعة البيانات الخام للتشخيص
      print('Raw data from Firestore:');
      result.docs.forEach((doc) {
        print('Document ID: ${doc.id}');
        print('Data: ${doc.data()}');
      });

      final List<Map<String, dynamic>> products = [];

      for (var doc in result.docs) {
        try {
          final data = doc.data();
          print('Processing product: ${data['name']}');
          print('Price type: ${data['price'].runtimeType}');
          print('Stock type: ${data['stock'].runtimeType}');

          // التحقق من وجود البيانات المطلوبة
          if (data['name'] == null) {
            print('Skipping product: name is null');
            continue;
          }

          // تحويل السعر
          double price = 0.0;
          if (data['price'] != null) {
            if (data['price'] is int) {
              price = (data['price'] as int).toDouble();
            } else if (data['price'] is double) {
              price = data['price'] as double;
            } else {
              print('Invalid price type: ${data['price'].runtimeType}');
              continue;
            }
          }

          // تحويل المخزون
          int stock = 0;
          if (data['stock'] != null) {
            if (data['stock'] is int) {
              stock = data['stock'] as int;
            } else if (data['stock'] is double) {
              stock = (data['stock'] as double).toInt();
            } else {
              print('Invalid stock type: ${data['stock'].runtimeType}');
              continue;
            }
          }

          products.add({
            'productId': doc.id, // استخدام معرف المستند كـ productId
            'name': data['name'].toString(),
            'price': price,
            'stock': stock,
          });

          print('Successfully added product: ${data['name']}');
        } catch (e) {
          print('Error processing product ${doc.id}: $e');
          continue;
        }
      }

      print('Processed ${products.length} valid products');
      products.forEach((product) {
        print(
            'Product: ${product['name']}, Stock: ${product['stock']}, ID: ${product['productId']}, Price: ${product['price']}');
      });

      if (products.isNotEmpty) {
        products.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));

        Get.dialog(
          ProductSelectionView(products: products),
          barrierDismissible: true,
        );
      } else {
        Get.snackbar(
          'تنبيه',
          'لا توجد منتجات صالحة في المخزن',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
        );
      }
    } catch (e, stackTrace) {
      print('Error loading products: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل المنتجات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDelegateDelivery() async {
    try {
      if (selectedProducts.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'يجب اختيار منتج واحد على الأقل',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final batch = FirebaseFirestore.instance.batch();

      // البحث عن تسليم موجود للمندوب
      final QuerySnapshot existingDeliverySnapshot = await FirebaseFirestore
          .instance
          .collection('delegate_deliveries')
          .where('delegateId', isEqualTo: delegateId)
          .limit(1)
          .get();

      DocumentReference deliveryRef;

      if (existingDeliverySnapshot.docs.isEmpty) {
        // إنشاء تسليم جديد إذا لم يكن موجوداً
        deliveryRef =
            FirebaseFirestore.instance.collection('delegate_deliveries').doc();
        batch.set(deliveryRef, {
          'delegateId': delegateId,
          'delegateName': delegateName,
          'products': selectedProducts
              .map((product) => {
                    'productId': product.productId,
                    'productName': product.productName,
                    'quantity': product.quantity,
                    'price': product.price,
                  })
              .toList(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // تحديث التسليم الموجود
        deliveryRef = existingDeliverySnapshot.docs.first.reference;

        // جلب المنتجات الحالية وتحديثها
        final Map<String, dynamic> currentData =
            existingDeliverySnapshot.docs.first.data() as Map<String, dynamic>;
        final List<dynamic> currentProducts = currentData['products'] ?? [];

        // تحويل المنتجات الحالية إلى Map للبحث السريع
        final Map<String, Map<String, dynamic>> productMap = {};
        for (var product in currentProducts) {
          productMap[product['productId']] = Map<String, dynamic>.from(product);
        }

        // تحديث أو إضافة المنتجات الجديدة
        for (var newProduct in selectedProducts) {
          if (productMap.containsKey(newProduct.productId)) {
            // تحديث الكمية للمنتج الموجود
            productMap[newProduct.productId]!['quantity'] +=
                newProduct.quantity;
          } else {
            // إضافة منتج جديد
            productMap[newProduct.productId] = {
              'productId': newProduct.productId,
              'productName': newProduct.productName,
              'quantity': newProduct.quantity,
              'price': newProduct.price,
            };
          }
        }

        batch.update(deliveryRef, {
          'products': productMap.values.toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // تحديث كميات المنتجات في المخزن
      for (var product in selectedProducts) {
        final productRef = FirebaseFirestore.instance
            .collection('products')
            .doc(product.productId);
        batch.update(productRef, {
          'stock': FieldValue.increment(-product.quantity),
        });
      }

      await batch.commit();

      Get.back();
      Get.snackbar(
        'تم بنجاح',
        'تم تحديث منتجات المندوب',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error saving delegate delivery: $e');
      Get.snackbar(
        'خطأ',
        'فشل تحديث منتجات المندوب',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // إضافة دالة للتحقق من وجود المنتج
  bool isProductSelected(String productId) {
    return selectedProducts.any((product) => product.productId == productId);
  }

  // إضافة دالة للحصول على index المنتج
  int getProductIndex(String productId) {
    return selectedProducts
        .indexWhere((product) => product.productId == productId);
  }

  void scrollToProduct(int index) {
    scrollToIndex.value = index;
    focusQuantityIndex.value = index;

    // إعادة تعيين القيم بعد التمرير
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollToIndex.value = -1;
      focusQuantityIndex.value = -1;
    });
  }

  void addProduct(Map<String, dynamic> product) {
    selectedProducts.insert(
        0,
        SelectedProduct(
          productId: product['productId'],
          productName: product['name'],
          quantity: 1,
          price: product['price'],
          availableQuantity: product['stock'],
        ));
    calculateTotals();
    Get.back();
  }
}
