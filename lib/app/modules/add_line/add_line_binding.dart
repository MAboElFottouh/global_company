import 'package:get/get.dart';
import 'add_line_controller.dart';

class AddLineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddLineController>(() => AddLineController());
  }
}
