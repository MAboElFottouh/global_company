import 'package:get/get.dart';

class SuperAdminController extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;

  void onAddAdminPressed() {
    // سيتم تنفيذ هذا عند الضغط على زر إضافة مسؤول
    Get.toNamed('/add-admin'); // سنقوم بإنشاء هذا المسار لاحقاً
  }

  void onManageAdminsPressed() {
    // سيتم تنفيذ هذا عند الضغط على زر إدارة المسؤولين
    Get.toNamed('/manage-admins'); // سنقوم بإنشاء هذا المسار لاحقاً
  }
}
