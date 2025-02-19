import 'package:get/get.dart';
import 'line_customers_reorder_controller.dart';

class LineCustomersReorderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LineCustomersReorderController>(
      () => LineCustomersReorderController(),
    );
  }
}
