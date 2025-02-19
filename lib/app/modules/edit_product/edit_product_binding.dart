import 'package:get/get.dart';
import 'edit_product_controller.dart';

class EditProductBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProductController>(
      () => EditProductController(
        productId: Get.arguments['productId'],
        productData: Get.arguments['productData'],
      ),
    );
  }
}
