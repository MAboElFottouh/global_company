import 'package:get/get.dart';
import '../add_customer/add_customer_controller.dart';

class ReviewCustomersController extends GetxController {
  final List<CustomerData> initialCustomers;
  late RxList<CustomerData> editableCustomers;
  late RxList<bool> selectedCustomers;
  final allSelected = false.obs;
  final selectedCount = 0.obs;

  ReviewCustomersController(this.initialCustomers) {
    editableCustomers = List<CustomerData>.from(initialCustomers).obs;
    selectedCustomers =
        List.generate(initialCustomers.length, (index) => true).obs;
    updateSelectedCount();
  }

  void toggleSelectAll(bool? value) {
    if (value != null) {
      for (var i = 0; i < selectedCustomers.length; i++) {
        selectedCustomers[i] = value;
      }
      allSelected.value = value;
      updateSelectedCount();
    }
  }

  void toggleCustomer(int index) {
    selectedCustomers[index] = !selectedCustomers[index];
    allSelected.value = selectedCustomers.every((element) => element);
    updateSelectedCount();
  }

  void updateSelectedCount() {
    selectedCount.value = selectedCustomers.where((element) => element).length;
  }

  void updateCustomerName(int index, String value) {
    editableCustomers[index] = CustomerData(
      name: value,
      phone: editableCustomers[index].phone,
      nickname: editableCustomers[index].nickname,
      ovenType: editableCustomers[index].ovenType,
    );
  }

  void updateCustomerPhone(int index, String value) {
    editableCustomers[index] = CustomerData(
      name: editableCustomers[index].name,
      phone: value,
      nickname: editableCustomers[index].nickname,
      ovenType: editableCustomers[index].ovenType,
    );
  }

  void updateCustomerNickname(int index, String value) {
    editableCustomers[index] = CustomerData(
      name: editableCustomers[index].name,
      phone: editableCustomers[index].phone,
      nickname: value,
      ovenType: editableCustomers[index].ovenType,
    );
  }

  void updateCustomerOvenType(int index, String value) {
    editableCustomers[index] = CustomerData(
      name: editableCustomers[index].name,
      phone: editableCustomers[index].phone,
      nickname: editableCustomers[index].nickname,
      ovenType: value,
    );
  }

  void saveSelectedCustomers(Function(List<CustomerData>) onSave) {
    final selectedData = editableCustomers
        .asMap()
        .entries
        .where((entry) => selectedCustomers[entry.key])
        .map((entry) => entry.value)
        .toList();
    onSave(selectedData);
  }
}
