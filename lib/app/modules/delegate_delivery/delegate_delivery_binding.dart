import 'package:get/get.dart';
import 'delegate_delivery_controller.dart';

class DelegateDeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegateDeliveryController>(
      () => DelegateDeliveryController(),
    );
  }
}
