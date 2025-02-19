import 'package:get/get.dart';
import 'manage_customers_controller.dart';

class ManageCustomersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageCustomersController>(() => ManageCustomersController());
  }
}
