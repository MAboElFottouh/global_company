import 'package:get/get.dart';
import 'manage_lines_controller.dart';

class ManageLinesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageLinesController>(() => ManageLinesController());
  }
}
