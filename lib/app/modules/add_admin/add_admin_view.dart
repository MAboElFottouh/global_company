import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_admin_controller.dart';

class AddAdminView extends GetView<AddAdminController> {
  AddAdminView({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    // حساب الارتفاع المتاح بعد خصم الـ status bar والـ bottom padding
    final availableHeight = screenHeight - padding.top - padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مسؤول جديد'),
      ),
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFBBDEFB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // المسافة العلوية المرنة
                        Flexible(
                          flex: 1,
                          child: Container(),
                        ),

                        Icon(
                          Icons.person_add,
                          size: screenHeight * 0.1, // حجم متناسب مع الشاشة
                          color: const Color(0xFF1E88E5),
                        ),
                        SizedBox(height: availableHeight * 0.02),
                        Text(
                          'إضافة مسؤول جديد',
                          style: TextStyle(
                            fontSize: screenHeight * 0.028,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E88E5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: availableHeight * 0.04),

                        // حقول الإدخال
                        TextFormField(
                          controller: nameController,
                          style: TextStyle(fontSize: screenHeight * 0.02),
                          decoration: InputDecoration(
                            labelText: 'اسم المسؤول',
                            prefixIcon: const Icon(Icons.person),
                            labelStyle:
                                TextStyle(fontSize: screenHeight * 0.018),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المسؤول';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: availableHeight * 0.02),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: screenHeight * 0.02),
                          maxLength: 11, // تحديد الحد الأقصى للأرقام
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف',
                            prefixIcon: const Icon(Icons.phone_android),
                            labelStyle:
                                TextStyle(fontSize: screenHeight * 0.018),
                            counterText: '', // إخفاء عداد الأحرف
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            if (int.tryParse(value) == null) {
                              return 'الرجاء إدخال أرقام فقط';
                            }
                            if (value.length != 11) {
                              return 'رقم الهاتف يجب أن يكون 11 رقم';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: availableHeight * 0.02),

                        // قائمة اختيار الصلاحيات
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Obx(() => DropdownButtonFormField<String>(
                                value: controller.selectedRole.value,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.admin_panel_settings),
                                ),
                                style: TextStyle(
                                  fontSize: screenHeight * 0.02,
                                  color: Colors.black87,
                                ),
                                items: controller.roles.map((role) {
                                  return DropdownMenuItem<String>(
                                    value: role['value'],
                                    child: Text(
                                      role['label']!,
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.02,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.selectedRole.value = value;
                                  }
                                },
                              )),
                        ),

                        SizedBox(height: availableHeight * 0.02),

                        // معلومات كلمة المرور
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(availableHeight * 0.02),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: screenHeight * 0.03,
                                ),
                                SizedBox(height: availableHeight * 0.01),
                                Text(
                                  'كلمة المرور الافتراضية هي: 123456',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenHeight * 0.016,
                                  ),
                                ),
                                Text(
                                  'يمكن للمسؤول تغييرها لاحقاً',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenHeight * 0.016,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: availableHeight * 0.03),

                        // زر الإضافة
                        Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        controller.addAdmin(
                                          nameController.text,
                                          phoneController.text,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: availableHeight * 0.02,
                                ),
                                minimumSize: Size(
                                    double.infinity, availableHeight * 0.06),
                              ),
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      width: screenHeight * 0.025,
                                      height: screenHeight * 0.025,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'إضافة المسؤول',
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.02,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            )),

                        // المسافة السفلية المرنة
                        Flexible(
                          flex: 2,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
