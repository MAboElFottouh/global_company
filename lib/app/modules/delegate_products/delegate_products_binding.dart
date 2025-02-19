import 'package:get/get.dart';
import 'delegate_products_controller.dart';

class DelegateProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegateProductsController>(
      () => DelegateProductsController(),
    );
  }
} 