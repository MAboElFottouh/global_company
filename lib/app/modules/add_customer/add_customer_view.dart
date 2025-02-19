import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_customer_controller.dart';
import 'package:flutter/services.dart';
import '../../routes/app_pages.dart';

class AddCustomerView extends GetView<AddCustomerController> {
  const AddCustomerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عميل جديد'),
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
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.person_add,
                  size: screenHeight * 0.1,
                  color: Colors.orange,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'إضافة عميل جديد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.026,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // اسم العميل
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم العميل',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // رقم الهاتف
                TextField(
                  controller: controller.phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: screenHeight * 0.02),

                // اللقب
                TextField(
                  controller: controller.nicknameController,
                  decoration: InputDecoration(
                    labelText: 'اللقب',
                    hintText: 'اختياري',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // نوع الفرن
                TextField(
                  controller: controller.ovenTypeController,
                  decoration: InputDecoration(
                    labelText: 'نوع الفرن',
                    hintText: 'اختياري',
                    prefixIcon: const Icon(Icons.local_fire_department),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // نسبة الخصم
                TextField(
                  controller: controller.discountController,
                  decoration: InputDecoration(
                    labelText: 'نسبة الخصم',
                    hintText: 'القيمة الافتراضية 0',
                    prefixIcon: const Icon(Icons.discount),
                    suffixText: '%',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // اختيار خط السير
                Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedLineId.value,
                      decoration: InputDecoration(
                        labelText: 'اختر خط السير',
                        prefixIcon: const Icon(Icons.route),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        // إضافة خيار إضافة خط سير جديد في بداية القائمة
                        const DropdownMenuItem(
                          value: 'add_new_line',
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.indigo,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'إضافة خط سير جديد',
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // إضافة خط فاصل
                        const DropdownMenuItem(
                          enabled: false,
                          child: Divider(thickness: 1),
                        ),
                        // إضافة باقي الخطوط
                        ...controller.lines.map((line) {
                          return DropdownMenuItem(
                            value: line.id,
                            child: Text(line['name']),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        if (value == 'add_new_line') {
                          Get.toNamed(Routes.ADD_LINE);
                          // إعادة تعيين القيمة المحددة إلى null
                          controller.selectedLineId.value = null;
                        } else {
                          controller.selectedLineId.value = value;
                        }
                      },
                    )),
                SizedBox(height: screenHeight * 0.04),

                // أزرار الإضافة والاستيراد
                Row(
                  children: [
                    // زر استيراد من ملف
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.importCustomers(),
                            icon: const Icon(Icons.file_upload),
                            label: const Text('استيراد من ملف'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    // زر إضافة عميل
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (controller.lines.isEmpty) {
                                      Get.dialog(
                                        AlertDialog(
                                          title: const Text('تنبيه'),
                                          content: const Text(
                                              'يجب إضافة خط سير واحد على الأقل قبل إضافة العملاء'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: const Text('إلغاء'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                                Get.toNamed('/add-line');
                                              },
                                              child: const Text('إضافة خط سير'),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }
                                    controller.addCustomer();
                                  },
                            icon: const Icon(Icons.person_add),
                            label: const Text('إضافة عميل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
