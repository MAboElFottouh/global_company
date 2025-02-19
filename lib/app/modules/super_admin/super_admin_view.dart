import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'super_admin_controller.dart';

class SuperAdminView extends GetView<SuperAdminController> {
  const SuperAdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المشرف الرئيسي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.offAllNamed('/login'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFBBDEFB)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Color(0xFF1E88E5),
              ),
              const SizedBox(height: 20),
              const Text(
                'إدارة المسؤولين',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // زر إضافة مسؤول جديد
              _buildAdminButton(
                icon: Icons.person_add,
                title: 'إضافة مسؤول جديد',
                subtitle: 'إضافة حساب مسؤول جديد للنظام',
                onPressed: () => controller.onAddAdminPressed(),
              ),

              const SizedBox(height: 20),

              // زر تعديل/حذف مسؤول
              _buildAdminButton(
                icon: Icons.manage_accounts,
                title: 'إدارة المسؤولين',
                subtitle: 'تعديل أو حذف حسابات المسؤولين',
                onPressed: () => controller.onManageAdminsPressed(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: const Color(0xFF1E88E5),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF1E88E5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
