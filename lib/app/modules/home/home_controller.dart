import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/session_service.dart';
import '../../auth/auth_controller.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isAdmin = false.obs;
  final userData = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final isDelegate = false.obs;
  final delegateProducts = 0.obs;
  final delegateBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    checkDelegateRole();
  }

  void loadUserData() {
    try {
      final sessionService = Get.find<SessionService>();
      userData.value = sessionService.currentUser;
      isAdmin.value = userData.value?['role'] == 'admin';
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> checkDelegateRole() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        isDelegate.value = userData['role'] == 'delegate';

        if (isDelegate.value) {
          loadDelegateInfo();
        }
      }
    } catch (e) {
      print('Error checking delegate role: $e');
    }
  }

  Future<void> loadDelegateInfo() async {
    try {
      isLoading.value = true;
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        delegateBalance.value = (userData['balance'] ?? 0.0).toDouble();
      }

      final QuerySnapshot<Map<String, dynamic>> deliveriesSnapshot =
          await _firestore
              .collection('delegate_deliveries')
              .where('delegateId', isEqualTo: currentUser.uid)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      print('Found ${deliveriesSnapshot.docs.length} deliveries');

      int totalProducts = 0;

      if (deliveriesSnapshot.docs.isNotEmpty) {
        final doc = deliveriesSnapshot.docs.first;
        final Map<String, dynamic> data = doc.data();
        final List<dynamic> products = data['products'] ?? [];

        print('Processing delivery: ${doc.id}');
        print('Delivery date: ${data['createdAt']}');
        print('Products in delivery: ${products.length}');

        for (var product in products) {
          final int quantity = product['quantity'] as int;
          totalProducts += quantity;
          print('Product: ${product['productName']}, Quantity: $quantity');
        }
      }

      delegateProducts.value = totalProducts;
      print('Total products for delegate: $totalProducts');
      print('Delegate balance: ${delegateBalance.value}');
    } catch (e, stackTrace) {
      print('Error loading delegate info: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }
}
