import 'package:get/get.dart';
import 'manage_admins_controller.dart';

class ManageAdminsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageAdminsController>(
      () => ManageAdminsController(),
    );
  }
}
