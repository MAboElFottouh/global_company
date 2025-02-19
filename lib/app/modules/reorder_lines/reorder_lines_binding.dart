import 'package:get/get.dart';
import 'reorder_lines_controller.dart';

class ReorderLinesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReorderLinesController>(
      () => ReorderLinesController(),
    );
  }
}
