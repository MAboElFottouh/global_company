import 'package:get/get.dart';
import 'add_purchases_controller.dart';

class AddPurchasesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddPurchasesController>(
      () => AddPurchasesController(),
    );
  }
}
