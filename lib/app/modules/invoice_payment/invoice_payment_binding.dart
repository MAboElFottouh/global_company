import 'package:get/get.dart';
import 'invoice_payment_controller.dart';

class InvoicePaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoicePaymentController>(
      () => InvoicePaymentController(
        customerId: Get.arguments['customerId'],
        customerName: Get.arguments['customerName'],
        delegateId: Get.arguments['delegateId'],
        totalAmount: Get.arguments['totalAmount'],
        products: Get.arguments['products'],
      ),
    );
  }
}
