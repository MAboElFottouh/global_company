import 'package:get/get.dart';
import '../../services/firebase_service.dart';
import '../../services/session_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseService(), permanent: true);
    Get.put(SessionService(), permanent: true);
  }
}
