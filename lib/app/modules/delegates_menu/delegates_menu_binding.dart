import 'package:get/get.dart';
import 'delegates_menu_controller.dart';

class DelegatesMenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegatesMenuController>(
      () => DelegatesMenuController(),
    );
  }
}
