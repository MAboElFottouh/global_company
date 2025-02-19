import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../manage_delegates_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignLineView extends GetView<ManageDelegatesController> {
  final String delegateId;
  final String delegateName;
  final DocumentSnapshot? assignment;

  const AssignLineView({
    Key? key,
    required this.delegateId,
    required this.delegateName,
    this.assignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assignment != null) {
      final assignmentData = assignment!.data() as Map<String, dynamic>;

      // تعديل طريقة البحث عن الخط
      try {
        final matchingLine = controller.lines.firstWhereOrNull(
          (line) => line.id == assignmentData['lineId'],
        );
        if (matchingLine != null) {
          controller.selectedLine.value = matchingLine;
        }
      } catch (e) {
        print('Error finding line: $e');
      }

      controller.assignPermanent.value = assignmentData['isPermanent'] ?? false;
      controller.assignNow.value = true;

      if (assignmentData['startDate'] != null) {
        controller.startDate.value =
            (assignmentData['startDate'] as Timestamp).toDate();
      }
      if (assignmentData['endDate'] != null) {
        controller.endDate.value =
            (assignmentData['endDate'] as Timestamp).toDate();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('تعيين خط سير لـ $delegateName'),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // اختيار خط السير
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اختر خط السير',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (controller.isLoadingLines.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return DropdownButtonFormField<DocumentSnapshot>(
                          value: controller.selectedLine.value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: controller.lines.map((line) {
                            final data = line.data() as Map<String, dynamic>;
                            return DropdownMenuItem(
                              value: line,
                              child: Text(data['name']),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              controller.selectedLine.value = value,
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // خيارات التعيين
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'خيارات التعيين',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => CheckboxListTile(
                            title: const Text('تعيين الخط من الآن'),
                            value: controller.assignNow.value ||
                                controller.assignPermanent.value,
                            onChanged: (value) {
                              if (!controller.assignPermanent.value) {
                                controller.assignNow.value = value ?? false;
                                if (value == true) {
                                  controller.assignPermanent.value = false;
                                  controller.startDate.value = DateTime.now();
                                } else {
                                  controller.startDate.value = null;
                                }
                              }
                            },
                          )),
                      Obx(() => CheckboxListTile(
                            title: const Text('تعيين الخط بشكل دائم'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حتى يتم تغييره يدوياً',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'سيظل الخط مُعين للمندوب حتى يتم تغييره من قبل المسؤول',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            value: controller.assignPermanent.value,
                            onChanged: (value) {
                              controller.assignPermanent.value = value ?? false;
                              if (value == true) {
                                controller.assignNow.value = true;
                                controller.startDate.value = DateTime.now();
                                controller.endDate.value = null;
                              }
                            },
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // تواريخ التعيين
              Obx(() {
                if (!controller.assignPermanent.value) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تواريخ التعيين',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!controller.assignNow.value) ...[
                            _buildDateField(
                              context,
                              'تاريخ البداية',
                              controller.startDate.value,
                              (date) => controller.startDate.value = date,
                              DateTime.now(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildDateField(
                            context,
                            'تاريخ الانتهاء',
                            controller.endDate.value,
                            (date) => controller.endDate.value = date,
                            controller.startDate.value
                                    ?.add(const Duration(days: 1)) ??
                                DateTime.now().add(const Duration(days: 1)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // التحقق من اختيار خط السير
            if (controller.selectedLine.value == null) {
              Get.snackbar(
                'خطأ',
                'برجاء اختيار خط السير',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[100],
                colorText: Colors.red[900],
              );
              return;
            }

            // التحقق من التواريخ حسب نوع التعيين
            if (controller.assignPermanent.value) {
              // في حالة التعيين الدائم، لا نحتاج للتحقق من التواريخ
              controller.assignLineToDelegate(
                delegateId,
                existingAssignmentId: assignment?.id,
              );
            } else if (controller.assignNow.value) {
              // في حالة التعيين من الآن، نتحقق من تاريخ الانتهاء فقط
              if (controller.endDate.value == null) {
                Get.snackbar(
                  'خطأ',
                  'برجاء تحديد تاريخ الانتهاء',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[900],
                );
                return;
              }
              controller.assignLineToDelegate(
                delegateId,
                existingAssignmentId: assignment?.id,
              );
            } else {
              // في حالة عدم اختيار نوع التعيين، نتحقق من وجود تاريخ البداية والنهاية
              if (controller.startDate.value == null ||
                  controller.endDate.value == null) {
                Get.snackbar(
                  'خطأ',
                  'برجاء تحديد تاريخ البداية والنهاية',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[900],
                );
                return;
              }
              controller.assignLineToDelegate(
                delegateId,
                existingAssignmentId: assignment?.id,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'تعيين الخط',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? value,
    Function(DateTime) onChanged,
    DateTime initialDate,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: initialDate,
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value?.toString().split(' ')[0] ?? 'اختر التاريخ',
              style: TextStyle(
                color: value == null ? Colors.grey : Colors.black87,
              ),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
