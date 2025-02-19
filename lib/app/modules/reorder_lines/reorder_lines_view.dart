import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reorder_lines_controller.dart';

class ReorderLinesView extends GetView<ReorderLinesController> {
  const ReorderLinesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترتيب خطوط السير'),
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.lines.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد خطوط',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.lines.length,
            onReorder: controller.updateLineOrder,
            itemBuilder: (context, index) {
              final line = controller.lines[index];
              final data = line.data()!;

              return Card(
                key: ValueKey(line.id),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.route,
                      color: Colors.teal,
                    ),
                  ),
                  title: Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: data['description'] != null
                      ? Text(
                          data['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => controller.showLineCustomers(line),
                        tooltip: 'عرض العملاء',
                      ),
                      IconButton(
                        icon: const Icon(Icons.sort_rounded),
                        onPressed: () => controller.showCustomersReorder(line),
                        tooltip: 'تعديل ترتيب العملاء',
                        color: Colors.orange,
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
}
