import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manage_lines_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;

class ManageLinesView extends GetView<ManageLinesController> {
  const ManageLinesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الخطوط'),
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

          if (controller.lines.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد خطوط حالياً',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: controller.lines.length,
            itemBuilder: (context, index) {
              final line = controller.lines[index];
              final createdBy = line['createdBy'] as Map<String, dynamic>;
              final createdAt = line['createdAt'] as Timestamp;
              final date = intl.DateFormat('yyyy/MM/dd - HH:mm')
                  .format(createdAt.toDate());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo[50],
                    child: const Icon(
                      Icons.route,
                      color: Colors.indigo,
                    ),
                  ),
                  title: Text(
                    line['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تم الإنشاء بواسطة: ${createdBy['name']}'),
                      Text('تاريخ الإنشاء: $date'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => _showEditDialog(context, line),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final result = await Get.dialog<bool>(
                            AlertDialog(
                              title: const Text('تأكيد الحذف'),
                              content:
                                  const Text('هل أنت متأكد من حذف خط السير؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () => Get.back(result: true),
                                  child: const Text(
                                    'حذف',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (result == true) {
                            controller.deleteLine(line.id);
                          }
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
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot line) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    controller.nameController.text = line['name'];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تعديل الخط',
                style: TextStyle(
                  fontSize: screenHeight * 0.024,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الخط',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.updateLine(line.id),
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
