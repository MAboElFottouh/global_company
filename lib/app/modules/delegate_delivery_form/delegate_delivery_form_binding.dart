import 'package:get/get.dart';
import 'delegate_delivery_form_controller.dart';

class DelegateDeliveryFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegateDeliveryFormController>(
      () => DelegateDeliveryFormController(
        delegateId: Get.arguments['delegateId'],
        delegateName: Get.arguments['delegateName'],
        currentBalance: Get.arguments['currentBalance'],
      ),
    );
  }
} 