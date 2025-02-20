import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'customer_returns_controller.dart';

class CustomerReturnsView extends GetView<CustomerReturnsController> {
  const CustomerReturnsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرتجع ${controller.customerName}'),
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

          if (controller.recentInvoices.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد مبيعات في آخر أسبوع',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.recentInvoices.length,
            itemBuilder: (context, index) {
              final invoice = controller.recentInvoices[index];
              final invoiceData = invoice.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    'التاريخ: ${controller.formatDate(invoiceData['createdAt'])}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'عدد الأصناف: ${(invoiceData['products'] as List).length}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<String>(
                        future: controller
                            .getDelegateName(invoiceData['delegateId']),
                        builder: (context, snapshot) {
                          return Text(
                            'المندوب: ${snapshot.data ?? 'جاري التحميل...'}',
                            style: const TextStyle(color: Colors.grey),
                          );
                        },
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${invoiceData['totalDue']} جنيه',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => controller.showInvoiceDetails(invoiceData),
                  isThreeLine: true,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
