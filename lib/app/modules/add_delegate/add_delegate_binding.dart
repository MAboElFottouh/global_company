import 'package:get/get.dart';
import 'add_delegate_controller.dart';

class AddDelegateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddDelegateController>(
      () => AddDelegateController(),
    );
  }
}
