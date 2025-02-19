import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل الدخول باستخدام رقم المستخدم وكلمة المرور
  Future<UserCredential?> signIn(String userNumber, String password) async {
    try {
      // البحث عن المستخدم في Firestore
      final userDoc = await _firestore
          .collection('users')
          .where('userNumber', isEqualTo: userNumber)
          .get();

      if (userDoc.docs.isEmpty) {
        throw 'مستخدم غير موجود';
      }

      // تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
      final email = userDoc.docs.first.data()['email'];
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // التحقق من حالة المستخدم
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // الحصول على بيانات المستخدم الحالي
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userData.docs.isNotEmpty) {
          return userData.docs.first.data();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
