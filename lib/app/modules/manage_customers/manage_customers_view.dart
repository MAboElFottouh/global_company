import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manage_customers_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import '../../routes/app_pages.dart';

class ManageCustomersView extends GetView<ManageCustomersController> {
  const ManageCustomersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء'),
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
            // شريط البحث
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: controller.searchController,
                    onChanged: controller.filterCustomers,
                    decoration: InputDecoration(
                      hintText: 'بحث...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // خيارات البحث
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'name',
                            groupValue: controller.searchType.value,
                            onChanged: (value) =>
                                controller.searchType.value = value!,
                          ),
                          const Text('الاسم'),
                          Radio<String>(
                            value: 'phone',
                            groupValue: controller.searchType.value,
                            onChanged: (value) =>
                                controller.searchType.value = value!,
                          ),
                          const Text('رقم الهاتف'),
                          Radio<String>(
                            value: 'nickname',
                            groupValue: controller.searchType.value,
                            onChanged: (value) =>
                                controller.searchType.value = value!,
                          ),
                          const Text('الشهرة'),
                        ],
                      )),
                ],
              ),
            ),

            // قائمة العملاء
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredCustomers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: screenHeight * 0.1,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا يوجد عملاء',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = controller.filteredCustomers[index];
                    final data = customer.data() as Map<String, dynamic>;
                    final createdAt = data['createdAt'] as Timestamp;
                    final date = intl.DateFormat('yyyy/MM/dd - HH:mm')
                        .format(createdAt.toDate());

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          data['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['phone']?.isNotEmpty ?? false)
                              Text('رقم الهاتف: ${data['phone']}'),
                            if (data['nickname']?.isNotEmpty ?? false)
                              Text('اللقب: ${data['nickname']}'),
                            if (data['ovenType']?.isNotEmpty ?? false)
                              Text('نوع الفرن: ${data['ovenType']}'),
                            Text('نسبة الخصم: ${data['discount']}%'),
                            Text('خط السير: ${data['line']['name']}'),
                            Text('تاريخ الإضافة: $date'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                Get.toNamed(
                                  Routes.EDIT_CUSTOMER,
                                  arguments: {
                                    'customerId': customer.id,
                                    'customerData': data,
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text(
                                        'هل أنت متأكد من حذف هذا العميل؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                          controller
                                              .deleteCustomer(customer.id);
                                        },
                                        child: const Text(
                                          'حذف',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
