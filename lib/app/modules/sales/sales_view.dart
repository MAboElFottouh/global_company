import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../routes/app_pages.dart';
import 'sales_controller.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المبيعات'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: controller.updateSearchQuery,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Obx(() => DropdownButtonFormField<String>(
                            value: controller.searchType.value,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'customerName',
                                child: Text('بحث باسم العميل'),
                              ),
                              DropdownMenuItem(
                                value: 'delegateName',
                                child: Text('بحث باسم المندوب'),
                              ),
                              DropdownMenuItem(
                                value: 'lineName',
                                child: Text('بحث باسم الخط'),
                              ),
                            ],
                            onChanged: (value) =>
                                controller.searchType.value = value!,
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final now = DateTime.now();
                          showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(now.year, now.month, now.day),
                            selectableDayPredicate: (DateTime date) {
                              return controller.hasInvoicesForDate(date);
                            },
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          ).then((picked) {
                            if (picked != null) {
                              controller.filterByDate(picked);
                            }
                          });
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('التاريخ'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.sales.isEmpty) {
                return const Center(
                  child: Text('لا توجد فواتير'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: controller.sales.length,
                itemBuilder: (context, index) {
                  final sale = controller.sales[index];
                  final date = (sale['createdAt'] as Timestamp).toDate();
                  final formattedDate =
                      DateFormat('yyyy/MM/dd - HH:mm').format(date);
                  final products = sale['products'] as List;
                  final totalItems = products.fold<num>(
                      0, (sum, product) => sum + (product['quantity'] as num));

                  return Card(
                    elevation: 2,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => Get.toNamed(
                        Routes.INVOICE_DETAILS,
                        arguments: {'invoice': sale},
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'العميل: ${sale['customerName']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'الخط: ${sale['lineName']}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                    formattedDate,
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildInfoChip(
                                    Icons.person_outline,
                                    sale['delegateName'].toString().length > 15
                                        ? '${sale['delegateName'].toString().substring(0, 15)}...'
                                        : sale['delegateName'].toString(),
                                    label: 'المندوب',
                                  ),
                                  const SizedBox(width: 12),
                                  _buildInfoChip(
                                    Icons.shopping_cart_outlined,
                                    totalItems.toString(),
                                    label: 'الأصناف',
                                  ),
                                  const SizedBox(width: 12),
                                  _buildInfoChip(
                                    Icons.attach_money,
                                    '${sale['total'].toStringAsFixed(2)} جنيه',
                                    label: 'الإجمالي',
                                    isTotal: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text,
      {bool isTotal = false, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isTotal ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTotal ? Colors.green[100]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isTotal ? Colors.green[700] : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isTotal ? Colors.green[700] : Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: isTotal ? Colors.green[700] : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
