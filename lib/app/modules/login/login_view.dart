import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    // حساب الارتفاع المتاح بعد خصم الـ status bar والـ bottom padding
    final availableHeight = screenHeight - padding.top - padding.bottom;

    return Scaffold(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // المسافة العلوية المرنة
                      Flexible(
                        flex: 2,
                        child: Container(),
                      ),

                      // الشعار والعنوان
                      Icon(
                        Icons.business,
                        size: screenHeight * 0.12, // حجم متناسب مع الشاشة
                        color: const Color(0xFF1E88E5),
                      ),
                      SizedBox(height: availableHeight * 0.02),
                      Text(
                        'الشركة العالمية',
                        style: TextStyle(
                          fontSize: screenHeight * 0.032, // حجم خط متناسب
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E88E5),
                        ),
                      ),
                      SizedBox(height: availableHeight * 0.04),

                      // نموذج تسجيل الدخول
                      TextField(
                        controller: usernameController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: screenHeight * 0.02),
                        decoration: InputDecoration(
                          labelText: 'رقم المستخدم',
                          prefixIcon: const Icon(Icons.phone_android),
                          labelStyle: TextStyle(fontSize: screenHeight * 0.018),
                        ),
                      ),
                      SizedBox(height: availableHeight * 0.02),
                      Obx(() => TextField(
                            controller: passwordController,
                            obscureText: controller.isPasswordHidden.value,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: screenHeight * 0.02),
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              labelStyle:
                                  TextStyle(fontSize: screenHeight * 0.018),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          )),
                      SizedBox(height: availableHeight * 0.03),
                      Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.login(
                                      usernameController.text,
                                      passwordController.text,
                                    ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                double.infinity,
                                availableHeight * 0.06,
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          )),

                      // المسافة السفلية المرنة
                      Flexible(
                        flex: 3,
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
    );
  }
}
