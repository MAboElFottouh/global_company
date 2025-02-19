import 'package:get/get.dart';
import 'edit_customer_controller.dart';

class EditCustomerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditCustomerController>(
      () => EditCustomerController(
        customerId: Get.arguments['customerId'],
        customerData: Get.arguments['customerData'],
      ),
    );
  }
}
