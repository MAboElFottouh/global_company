import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../routes/app_pages.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: screenHeight * 0.2,
              ),
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // بطاقة معلومات المستخدم
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: screenHeight * 0.04,
                              backgroundColor: Colors.blue[50],
                              child: Icon(
                                Icons.person,
                                size: screenHeight * 0.04,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              controller.userData.value?['name'] ?? '',
                              style: TextStyle(
                                fontSize: screenHeight * 0.024,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              controller.userData.value?['userNumber'] ?? '',
                              style: TextStyle(
                                fontSize: screenHeight * 0.018,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getRoleInArabic(
                                    controller.userData.value?['role']),
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: screenHeight * 0.016,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // الإعدادات العامة
                    Text(
                      'الإعدادات العامة',
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // زر تغيير كلمة المرور فقط
                    _buildSettingCard(
                      context: context,
                      icon: Icons.lock_outline,
                      title: 'تغيير كلمة المرور',
                      color: Colors.green,
                      onTap: () => _showChangePasswordDialog(context),
                    ),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لتحويل نوع المستخدم للعربية
  String _getRoleInArabic(String? role) {
    switch (role) {
      case 'admin':
        return 'مسؤول';
      case 'storekeeper':
        return 'أمين مخزن';
      case 'delegate':
        return 'مندوب';
      default:
        return 'مستخدم';
    }
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.018,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: screenHeight * 0.035,
                  backgroundColor: Colors.green[50],
                  child: const Icon(Icons.lock_outline, color: Colors.green),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'تغيير كلمة المرور',
                  style: TextStyle(
                    fontSize: screenHeight * 0.022,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                TextField(
                  controller: controller.oldPasswordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور القديمة',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: controller.newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: controller.confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور الجديدة',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    controller.updatePassword();
                                  },
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('تغيير'),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
