import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/selected_product.dart';
import 'package:flutter/material.dart';
import '../home/home_controller.dart';
import '../../routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerSaleController extends GetxController {
  final String customerId;
  final String customerName;
  final String delegateId;
  final String delegateName;
  final discount = 0.0.obs;
  final products = <Map<String, dynamic>>[].obs;
  final selectedProducts = <SelectedProduct>[].obs;
  final isLoading = true.obs;
  final totalAmount = 0.0.obs;
  final totalAfterDiscount = 0.0.obs;
  final totalQuantity = 0.obs;
  final scrollToIndex = (-1).obs;
  final focusQuantityIndex = (-1).obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CustomerSaleController({
    required this.customerId,
    required this.customerName,
    required this.delegateId,
    required this.delegateName,
  });

  @override
  void onInit() {
    super.onInit();
    loadDelegateProducts();
    loadCustomerDiscount();
  }

  Future<void> loadDelegateProducts() async {
    try {
      isLoading.value = true;
      products.clear(); // تنظيف القائمة القديمة

      // جلب المنتجات المتاحة مع المندوب
      final QuerySnapshot<Map<String, dynamic>> deliveriesSnapshot =
          await FirebaseFirestore.instance
              .collection('delegate_deliveries')
              .where('delegateId', isEqualTo: delegateId)
              .get();

      if (deliveriesSnapshot.docs.isEmpty) {
        print('No deliveries found for delegate: $delegateId');
        Get.back();
        Get.snackbar(
          'تنبيه',
          'لا يوجد منتجات متاحة مع المندوب',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          duration: const Duration(seconds: 3),
        );
        return;
      }

      print('Found ${deliveriesSnapshot.docs.length} deliveries');

      // جلب آخر تسليم للمندوب
      final doc = deliveriesSnapshot.docs.first;
      final deliveryData = doc.data();
      final List<dynamic> deliveryProducts = deliveryData['products'] ?? [];

      print('Processing delivery: ${doc.id} at ${deliveryData['createdAt']}');
      print('Products in delivery: ${deliveryProducts.length}');

      // تحويل المنتجات إلى الشكل المطلوب
      products.value = deliveryProducts
          .where((product) => (product['quantity'] as int) > 0)
          .map((product) => {
                'productId': product['productId'],
                'productName': product['productName'],
                'price': product['price'],
                'availableQuantity': product['quantity'],
              })
          .toList();

      print('\nAvailable products:');
      products.forEach((product) {
        print('${product['productName']}: ${product['availableQuantity']}');
      });

      // ترتيب المنتجات حسب الاسم
      products.sort((a, b) =>
          (a['productName'] as String).compareTo(b['productName'] as String));
    } catch (e) {
      print('Error loading delegate products: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل المنتجات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomerDiscount() async {
    try {
      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .get();

      if (customerDoc.exists) {
        final customerData = customerDoc.data();
        discount.value = (customerData?['discount'] ?? 0.0).toDouble();
      }
    } catch (e) {
      print('خطأ في تحميل نسبة الخصم: $e');
      discount.value = 0.0;
    }
  }

  // دالة مساعدة لحساب الكمية المباعة من المنتج
  Future<int> getSoldQuantity(String productId) async {
    try {
      final QuerySnapshot salesSnapshot = await FirebaseFirestore.instance
          .collection('customer_sales')
          .where('delegateId', isEqualTo: delegateId)
          .get();

      int totalSold = 0;
      for (var sale in salesSnapshot.docs) {
        final data = sale.data() as Map<String, dynamic>;
        final List<dynamic> products = data['products'] ?? [];

        for (var product in products) {
          if (product['productId'] == productId) {
            totalSold += product['quantity'] as int;
          }
        }
      }

      return totalSold;
    } catch (e) {
      print('Error calculating sold quantity: $e');
      return 0;
    }
  }

  void updateQuantity(int index, int quantity) {
    // التحقق من أن الكمية المدخلة لا تتجاوز الكمية المتاحة
    if (quantity > selectedProducts[index].availableQuantity) {
      Get.snackbar(
        'تنبيه',
        'الكمية المتاحة ${selectedProducts[index].availableQuantity} فقط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
      );
      // تحديث الكمية إلى الحد الأقصى المتاح
      quantity = selectedProducts[index].availableQuantity;
    }

    // تحديث المنتج بالكمية الجديدة
    final updatedProduct = SelectedProduct(
      productId: selectedProducts[index].productId,
      productName: selectedProducts[index].productName,
      quantity: quantity,
      price: selectedProducts[index].price,
      availableQuantity: selectedProducts[index].availableQuantity,
    );
    selectedProducts[index] = updatedProduct;
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
    totalAfterDiscount.value = amount - (amount * (discount.value / 100));
  }

  Future<void> saveSale() async {
    try {
      if (selectedProducts.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'يجب اختيار منتج واحد على الأقل',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // طباعة للتأكد من البيانات
      print('Navigating to invoice payment with:');
      print('customerId: $customerId');
      print('customerName: $customerName');
      print('delegateId: $delegateId');
      print('totalAmount: ${totalAfterDiscount.value}');

      // تعديل طريقة التوجيه
      await Get.toNamed(
        Routes.INVOICE_PAYMENT,
        arguments: {
          'customerId': customerId,
          'customerName': customerName,
          'delegateId': delegateId,
          'totalAmount': totalAfterDiscount.value,
          'products': selectedProducts
              .map((product) => {
                    'productId': product.productId,
                    'productName': product.productName,
                    'quantity': product.quantity,
                    'price': product.price,
                    'originalPrice': product.price,
                    'discount': discount.value,
                  })
              .toList(),
        },
        preventDuplicates: false, // للسماح بفتح الصفحة حتى لو كانت مفتوحة
      );

      // لا نحتاج إلى التحقق من النتيجة هنا لأن InvoicePaymentController سيتعامل مع الرجوع
    } catch (e) {
      print('Error navigating to invoice payment: $e');
      Get.snackbar(
        'خطأ',
        'فشل فتح صفحة إصدار الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  bool isProductSelected(String productId) {
    return selectedProducts.any((product) => product.productId == productId);
  }

  int getProductIndex(String productId) {
    return selectedProducts
        .indexWhere((product) => product.productId == productId);
  }

  void addProduct(Map<String, dynamic> product) {
    selectedProducts.insert(
      0,
      SelectedProduct(
        productId: product['productId'],
        productName: product['productName'],
        quantity: 1,
        price: product['price'],
        availableQuantity: product['availableQuantity'],
      ),
    );
    calculateTotals();
    Get.back();
  }

  void removeProduct(int index) {
    selectedProducts.removeAt(index);
    calculateTotals();
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

  Future<void> createInvoice() async {
    try {
      isLoading.value = true;

      // استخدام المعلومات الموجودة في الكاش
      final invoice = {
        'customerId': customerId,
        'customerName': customerName,
        'products': selectedProducts
            .map((product) => {
                  'productId': product.productId,
                  'productName': product.productName,
                  'quantity': product.quantity,
                  'price': product.price,
                  'originalPrice': product.price,
                  'priceAfterDiscount':
                      product.price - (product.price * (discount.value / 100)),
                  'total': product.total,
                  'totalAfterDiscount':
                      product.total - (product.total * (discount.value / 100)),
                })
            .toList(),
        'total': totalAmount.value,
        'totalAfterDiscount': totalAfterDiscount.value,
        'discount': discount.value,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'delegateId': delegateId,
        'delegateName': delegateName,
      };

      // حفظ الفاتورة في Firestore
      final docRef = await _firestore.collection('invoices').add(invoice);

      Get.snackbar(
        'نجاح',
        'تم إنشاء الفاتورة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );

      // الانتقال إلى صفحة الدفع
      Get.toNamed(
        Routes.INVOICE_PAYMENT,
        arguments: {
          'invoice': {
            'id': docRef.id,
            ...invoice,
          }
        },
      );
    } catch (e) {
      print('Error creating invoice: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
