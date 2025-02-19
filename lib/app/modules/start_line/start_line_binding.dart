import 'package:get/get.dart';
import 'start_line_controller.dart';

class StartLineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StartLineController>(
      () => StartLineController(),
    );
  }
}
