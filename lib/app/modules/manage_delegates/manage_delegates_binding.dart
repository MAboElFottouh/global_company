import 'package:get/get.dart';
import 'manage_delegates_controller.dart';

class ManageDelegatesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageDelegatesController>(
      () => ManageDelegatesController(),
    );
  }
}
