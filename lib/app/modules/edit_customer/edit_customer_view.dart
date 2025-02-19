import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_customer_controller.dart';
import 'package:flutter/services.dart';

class EditCustomerView extends GetView<EditCustomerController> {
  const EditCustomerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات العميل'),
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
                  Icons.edit_note,
                  size: screenHeight * 0.1,
                  color: Colors.blue,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'تعديل بيانات العميل',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.026,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
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
                      items: controller.lines.map((line) {
                        return DropdownMenuItem(
                          value: line.id,
                          child: Text(line['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedLineId.value = value;
                      },
                    )),
                SizedBox(height: screenHeight * 0.04),

                // زر الحفظ
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.updateCustomer(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'حفظ التغييرات',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
