import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_customer/add_customer_controller.dart';
import 'review_customers_controller.dart';

class ReviewCustomersView extends GetView<ReviewCustomersController> {
  final List<CustomerData> customers;
  final Function(List<CustomerData>) onSave;

  const ReviewCustomersView({
    Key? key,
    required this.customers,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة بيانات العملاء'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFBBDEFB)],
          ),
        ),
        child: Column(
          children: [
            // شريط الأدوات
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Obx(() => Checkbox(
                        value: controller.allSelected.value,
                        onChanged: controller.toggleSelectAll,
                      )),
                  const Text('تحديد الكل'),
                  const Spacer(),
                  Text(
                    'إجمالي العملاء: ${customers.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),

            // قائمة العملاء
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Obx(() => Checkbox(
                                    value: controller.selectedCustomers[index],
                                    onChanged: (value) =>
                                        controller.toggleCustomer(index),
                                  )),
                              Text(
                                'عميل ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue:
                                controller.editableCustomers[index].name,
                            decoration: const InputDecoration(
                              labelText: 'اسم العميل',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                controller.updateCustomerName(index, value),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue:
                                controller.editableCustomers[index].phone ?? '',
                            decoration: const InputDecoration(
                              labelText: 'رقم الهاتف',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                controller.updateCustomerPhone(index, value),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue:
                                controller.editableCustomers[index].nickname ??
                                    '',
                            decoration: const InputDecoration(
                              labelText: 'اللقب',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                controller.updateCustomerNickname(index, value),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue:
                                controller.editableCustomers[index].ovenType ??
                                    '',
                            decoration: const InputDecoration(
                              labelText: 'نوع الفرن',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                controller.updateCustomerOvenType(index, value),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('إلغاء'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => ElevatedButton(
                    onPressed: controller.selectedCount.value > 0
                        ? () => controller.saveSelectedCustomers(onSave)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        Text('حفظ المحدد (${controller.selectedCount.value})'),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
