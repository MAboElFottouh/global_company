import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'invoice_details_controller.dart';

class InvoiceDetailsView extends GetView<InvoiceDetailsController> {
  const InvoiceDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفاتورة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات العميل
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات العميل',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      _buildInfoRow(
                          'اسم العميل:', controller.invoice['customerName']),
                      _buildInfoRow('الخط:',
                          '${controller.invoice['lineName']} ${controller.invoice['lineNickname']}'),
                      _buildInfoRow(
                          'نوع الفرن:', controller.invoice['ovenType']),
                      _buildInfoRow(
                          'رقم الهاتف:', controller.invoice['customerPhone']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // تفاصيل المنتجات
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المنتجات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            (controller.invoice['products'] as List).length,
                        itemBuilder: (context, index) {
                          final product = controller.invoice['products'][index];
                          return ListTile(
                            title: Text(product['productName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الكمية: ${product['quantity']}'),
                                Text(
                                    'السعر: ${product['price'].toStringAsFixed(2)} جنيه'),
                                if (product['discount'] > 0)
                                  Text(
                                    'نسبة الخصم: ${product['discount']}%',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              '${(product['price'] * product['quantity']).toStringAsFixed(2)} جنيه',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ملخص الفاتورة
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إجمالي الفاتورة:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ملخص الفاتورة',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      _buildInfoRow('إجمالي المنتجات:',
                          '${controller.subtotal.toStringAsFixed(2)} جنيه'),
                      if (controller.totalDiscount > 0)
                        _buildInfoRow('إجمالي نسبة الخصم:',
                            '${controller.totalDiscount}%',
                            isDiscount: true),
                      _buildInfoRow('المبلغ المدفوع:',
                          '${controller.invoice['paidAmount'].toStringAsFixed(2)} جنيه'),
                      _buildInfoRow('المبلغ المتبقي:',
                          '${controller.invoice['remainingAmount'].toStringAsFixed(2)} جنيه'),
                      const Divider(),
                      _buildInfoRow(
                        'الإجمالي النهائي:',
                        '${controller.total.toStringAsFixed(2)} جنيه',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isDiscount ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
