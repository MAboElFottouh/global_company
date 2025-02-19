import 'package:get/get.dart';
import 'manage_products_controller.dart';

class ManageProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageProductsController>(() => ManageProductsController());
  }
}
