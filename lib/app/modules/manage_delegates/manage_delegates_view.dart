import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manage_delegates_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'views/assign_line_view.dart';
import 'package:intl/intl.dart';

class ManageDelegatesView extends GetView<ManageDelegatesController> {
  const ManageDelegatesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المناديب'),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.filterDelegates,
                decoration: InputDecoration(
                  hintText: 'بحث باسم المندوب أو رقم الهاتف...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // قائمة المناديب
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredDelegates.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا يوجد مناديب',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.filteredDelegates.length,
                  itemBuilder: (context, index) {
                    final delegate = controller.filteredDelegates[index];
                    final data = delegate.data() as Map<String, dynamic>;

                    // عرض المناديب فقط
                    if (data['role'] != 'delegate')
                      return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.indigo[700],
                              ),
                            ),
                            title: Text(
                              data['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('رقم الهاتف: ${data['userNumber']}'),
                                Text('الصلاحية: مندوب'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => Get.to(() => AssignLineView(
                                        delegateId: delegate.id,
                                        delegateName: data['name'],
                                      )),
                                  icon: const Icon(Icons.add_road, size: 18),
                                  label: const Text('تعيين خط'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // عرض الخطوط المعينة
                          Obx(() {
                            final assignments =
                                controller.delegateAssignments[delegate.id] ??
                                    [];
                            if (assignments.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'لا توجد خطوط معينة',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: assignments.map((assignment) {
                                final assignmentData =
                                    assignment.data() as Map<String, dynamic>;
                                return Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.route,
                                              size: 20,
                                              color: Colors.teal[700]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'خط: ${assignmentData['lineName']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          if (assignmentData['isPermanent'])
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.teal[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.teal[100]!),
                                              ),
                                              child: Text(
                                                'دائم',
                                                style: TextStyle(
                                                  color: Colors.teal[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (!assignmentData['isPermanent']) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            Text(
                                              'من: ${_formatDate(assignmentData['startDate'])}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              'إلى: ${_formatDate(assignmentData['endDate'])}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () =>
                                                Get.to(() => AssignLineView(
                                                      delegateId: delegate.id,
                                                      delegateName:
                                                          data['name'],
                                                      assignment: assignment,
                                                    )),
                                            icon: const Icon(Icons.edit_road,
                                                size: 18),
                                            label: const Text('تعديل'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.blue[700],
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton.icon(
                                            onPressed: () =>
                                                _showCancelConfirmation(
                                              context,
                                              assignment.id,
                                              assignmentData['lineName'],
                                            ),
                                            icon: const Icon(
                                                Icons.cancel_outlined,
                                                size: 18),
                                            label: const Text('إلغاء'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red[700],
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                        ],
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

  void _showAssignLineDialog(
      BuildContext context, String delegateId, String delegateName) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // العنوان
                Row(
                  children: [
                    const Icon(Icons.route, color: Colors.teal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'تعيين خط سير لـ $delegateName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const Divider(height: 25),

                // المحتوى
                Flexible(
                  child: SingleChildScrollView(
                    child: Obx(() {
                      if (controller.isLoadingLines.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // اختيار خط السير
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: DropdownButtonFormField<DocumentSnapshot>(
                              value: controller.selectedLine.value,
                              decoration: InputDecoration(
                                labelText: 'اختر خط السير',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: controller.lines.map((line) {
                                final data =
                                    line.data() as Map<String, dynamic>;
                                return DropdownMenuItem(
                                  value: line,
                                  child: Text(data['name']),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  controller.selectedLine.value = value,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // خيارات التعيين
                          Card(
                            elevation: 0,
                            color: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Obx(() => CheckboxListTile(
                                      title: const Text('تعيين الخط من الآن'),
                                      value: controller.assignNow.value ||
                                          controller.assignPermanent.value,
                                      onChanged: (value) {
                                        if (!controller.assignPermanent.value) {
                                          controller.assignNow.value =
                                              value ?? false;
                                          if (value == true) {
                                            controller.assignPermanent.value =
                                                false;
                                            controller.startDate.value =
                                                DateTime.now();
                                          } else {
                                            controller.startDate.value = null;
                                          }
                                        }
                                      },
                                    )),
                                Obx(() => CheckboxListTile(
                                      title: Flexible(
                                        child: Row(
                                          children: [
                                            const Flexible(
                                              child: Text(
                                                'تعيين الخط بشكل دائم',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Tooltip(
                                              message:
                                                  'سيظل الخط مُعين للمندوب حتى يتم تغييره يدوياً',
                                              child: Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Text(
                                        'حتى يتم تغييره يدوياً',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      value: controller.assignPermanent.value,
                                      onChanged: (value) {
                                        controller.assignPermanent.value =
                                            value ?? false;
                                        if (value == true) {
                                          controller.assignNow.value = true;
                                          controller.startDate.value =
                                              DateTime.now();
                                          controller.endDate.value = null;
                                        }
                                      },
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // تواريخ البداية والنهاية
                          Obx(() {
                            Widget dateWidget = const SizedBox.shrink();

                            if (controller.assignNow.value &&
                                !controller.assignPermanent.value) {
                              dateWidget = Card(
                                elevation: 0,
                                color: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _buildDateTile(
                                  title: 'تاريخ الانتهاء',
                                  date: controller.endDate.value,
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now()
                                          .add(const Duration(days: 1)),
                                      firstDate: DateTime.now()
                                          .add(const Duration(days: 1)),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      controller.endDate.value = date;
                                    }
                                  },
                                ),
                              );
                            } else if (!controller.assignNow.value &&
                                !controller.assignPermanent.value) {
                              dateWidget = Card(
                                elevation: 0,
                                color: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    _buildDateTile(
                                      title: 'تاريخ البداية',
                                      date: controller.startDate.value,
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                        );
                                        if (date != null) {
                                          controller.startDate.value = date;
                                        }
                                      },
                                    ),
                                    const Divider(height: 1),
                                    _buildDateTile(
                                      title: 'تاريخ الانتهاء',
                                      date: controller.endDate.value,
                                      onTap: () async {
                                        if (controller.startDate.value ==
                                            null) {
                                          Get.snackbar(
                                            'تنبيه',
                                            'برجاء اختيار تاريخ البداية أولاً',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                          return;
                                        }
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: controller
                                              .startDate.value!
                                              .add(const Duration(days: 1)),
                                          firstDate: controller.startDate.value!
                                              .add(const Duration(days: 1)),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                        );
                                        if (date != null) {
                                          controller.endDate.value = date;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }

                            return dateWidget;
                          }),
                        ],
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 24),

                // أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          controller.assignLineToDelegate(delegateId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('تعيين'),
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

  Widget _buildDateTile({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        date?.toString().split(' ')[0] ?? 'اختر التاريخ',
        style: TextStyle(
          color: date == null ? Colors.grey : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: onTap,
    );
  }

  // دالة مساعدة لتنسيق التاريخ
  String _formatDate(dynamic date) {
    if (date == null) return 'غير محدد';
    if (date is Timestamp) {
      return DateFormat('yyyy/MM/dd').format(date.toDate());
    }
    return 'غير محدد';
  }

  // دالة لعرض تأكيد إلغاء التعيين
  void _showCancelConfirmation(
      BuildContext context, String assignmentId, String lineName) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد إلغاء التعيين'),
        content: Text('هل أنت متأكد من إلغاء تعيين خط "$lineName"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelAssignment(assignmentId);
            },
            child: const Text('تأكيد'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
