import 'package:get/get.dart';
import 'customer_returns_controller.dart';

class CustomerReturnsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerReturnsController>(
      () => CustomerReturnsController(),
    );
  }
}
