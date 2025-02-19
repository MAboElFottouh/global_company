import 'package:get/get.dart';
import 'manage_purchases_controller.dart';

class ManagePurchasesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagePurchasesController>(
      () => ManagePurchasesController(),
    );
  }
}
