import 'package:get/get.dart';
import 'review_customers_controller.dart';

class ReviewCustomersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewCustomersController>(
      () => ReviewCustomersController(Get.arguments['customers']),
    );
  }
}
