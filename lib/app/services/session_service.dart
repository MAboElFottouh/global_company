import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService extends GetxService {
  final _storage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final userData = Rxn<Map<String, dynamic>>();

  // مفاتيح التخزين
  static const String USER_DATA_KEY = 'userData';
  static const String IS_LOGGED_IN_KEY = 'isLoggedIn';

  @override
  void onInit() {
    super.onInit();
    // محاولة استرجاع بيانات المستخدم من التخزين المحلي
    final storedData = _storage.read(USER_DATA_KEY);
    if (storedData != null) {
      userData.value = Map<String, dynamic>.from(storedData);
    }
  }

  // حفظ بيانات المستخدم
  Future<void> saveUserSession(DocumentSnapshot userDoc) async {
    final data = userDoc.data() as Map<String, dynamic>;
    data['uid'] = userDoc.id;

    await _storage.write(USER_DATA_KEY, data);
    await _storage.write(IS_LOGGED_IN_KEY, true);

    userData.value = data;
  }

  // التحقق من وجود جلسة مستخدم
  bool get isLoggedIn => _storage.read(IS_LOGGED_IN_KEY) ?? false;

  // تحديث بيانات المستخدم
  Future<void> updateUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        await saveUserSession(doc);
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  // تسجيل الخروج
  Future<void> clearSession() async {
    await _storage.remove(USER_DATA_KEY);
    await _storage.remove(IS_LOGGED_IN_KEY);
    userData.value = null;
  }

  // الحصول على بيانات المستخدم
  Map<String, dynamic>? get currentUser => userData.value;
}
