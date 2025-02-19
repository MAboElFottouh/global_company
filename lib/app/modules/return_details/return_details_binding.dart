import 'package:get/get.dart';
import 'return_details_controller.dart';

class ReturnDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReturnDetailsController>(
      () => ReturnDetailsController(),
    );
  }
}
