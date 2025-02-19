import 'package:get/get.dart';
import 'line_customers_controller.dart';

class LineCustomersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LineCustomersController>(
      () => LineCustomersController(),
    );
  }
}
