import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manage_admins_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAdminsView extends GetView<ManageAdminsController> {
  const ManageAdminsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المسؤولين'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFBBDEFB)],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.users.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد مسؤولين حالياً',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              final isAdmin = user['role'] == 'admin';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user['role'] == 'admin'
                        ? Colors.blue
                        : user['role'] == 'storekeeper'
                            ? Color(0xFF2E7D32)
                            : Colors.green,
                    child: Icon(
                      user['role'] == 'admin'
                          ? Icons.admin_panel_settings
                          : user['role'] == 'storekeeper'
                              ? Icons.store
                              : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    user['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: user['role'] == 'admin'
                          ? Colors.blue[900]
                          : user['role'] == 'storekeeper'
                              ? Color(0xFF1B5E20)
                              : Colors.green[900],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رقم الهاتف: ${user['userNumber']}'),
                      Text(
                        'الصلاحية: ${user['role'] == 'admin' ? 'مسؤول' : user['role'] == 'storekeeper' ? 'أمين مخزن' : 'مندوب'}',
                        style: TextStyle(
                          color: user['role'] == 'admin'
                              ? Colors.blue
                              : user['role'] == 'storekeeper'
                                  ? Color(0xFF2E7D32)
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => _showEditDialog(context, user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () =>
                            _showDeleteConfirmation(context, user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot user) {
    controller.startEditing(user);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isAdmin = user['role'] == 'admin';

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
                  backgroundColor: isAdmin ? Colors.blue[50] : Colors.green[50],
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: isAdmin ? Colors.blue : Colors.green,
                    size: screenHeight * 0.035,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'تعديل بيانات ${isAdmin ? "المسؤول" : "المندوب"}',
                  style: TextStyle(
                    fontSize: screenHeight * 0.022,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: screenHeight * 0.018,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: controller.nameController,
                    style: TextStyle(fontSize: screenHeight * 0.018),
                    decoration: InputDecoration(
                      labelText: 'الاسم',
                      labelStyle: TextStyle(fontSize: screenHeight * 0.016),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: controller.phoneController,
                    style: TextStyle(fontSize: screenHeight * 0.018),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      labelStyle: TextStyle(fontSize: screenHeight * 0.016),
                      prefixIcon: const Icon(Icons.phone_android_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedRole.value,
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color: Colors.black87,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings,
                                    color: Colors.blue[700],
                                    size: screenHeight * 0.024),
                                SizedBox(width: screenWidth * 0.02),
                                Text('مسؤول',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'storekeeper',
                            child: Row(
                              children: [
                                Icon(Icons.store,
                                    color: Color(0xFF2E7D32),
                                    size: screenHeight * 0.024),
                                SizedBox(width: screenWidth * 0.02),
                                Text('أمين مخزن',
                                    style: TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'delegate',
                            child: Row(
                              children: [
                                Icon(Icons.person_outline,
                                    color: Colors.green[700],
                                    size: screenHeight * 0.024),
                                SizedBox(width: screenWidth * 0.02),
                                Text('مندوب',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedRole.value = value;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'الصلاحية',
                          labelStyle: TextStyle(fontSize: screenHeight * 0.016),
                          prefixIcon: const Icon(Icons.security_outlined),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                      )),
                ),
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined,
                                  color: Colors.grey,
                                  size: screenHeight * 0.024),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenHeight * 0.016,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.validateAndUpdate(user.id);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015),
                            backgroundColor: Colors.blue,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined,
                                  color: Colors.white,
                                  size: screenHeight * 0.024),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                'حفظ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.016,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(userId);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
