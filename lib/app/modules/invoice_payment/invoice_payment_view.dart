import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'invoice_payment_controller.dart';

class InvoicePaymentView extends GetView<InvoicePaymentController> {
  const InvoicePaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoicePaymentController>(
      init: InvoicePaymentController(
        customerId: Get.arguments['customerId'],
        customerName: Get.arguments['customerName'],
        delegateId: Get.arguments['delegateId'],
        totalAmount: Get.arguments['totalAmount'],
        products: Get.arguments['products'],
      ),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('إصدار الفاتورة'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات العميل والفاتورة
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'العميل: ${controller.customerName}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        // تفاصيل المبالغ
                        GetX<InvoicePaymentController>(
                          builder: (ctrl) => Column(
                            children: [
                              _buildAmountRow(
                                'الرصيد السابق',
                                ctrl.previousBalance.value,
                                Colors.orange,
                              ),
                              const SizedBox(height: 8),
                              _buildAmountRow(
                                'قيمة الفاتورة',
                                ctrl.totalAmount,
                                Colors.green,
                              ),
                              if (ctrl.paymentType.value !=
                                  PaymentType.full) ...[
                                const SizedBox(height: 8),
                                _buildAmountRow(
                                  'المبلغ المتبقي',
                                  ctrl.remainingAmount.value,
                                  Colors.red,
                                ),
                              ],
                              const Divider(height: 24),
                              _buildAmountRow(
                                'إجمالي المستحق',
                                ctrl.totalBalance.value,
                                Colors.blue,
                                large: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // طرق الدفع
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.payment, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'طريقة الدفع',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GetX<InvoicePaymentController>(
                          builder: (ctrl) => Column(
                            children: [
                              _buildPaymentOption(
                                PaymentType.full,
                                'دفع كامل المبلغ',
                                Icons.check_circle_outline,
                                ctrl,
                              ),
                              _buildPaymentOption(
                                PaymentType.partial,
                                'دفع جزء من المبلغ',
                                Icons.pie_chart_outline,
                                ctrl,
                              ),
                              _buildPaymentOption(
                                PaymentType.delayed,
                                'آجل',
                                Icons.schedule,
                                ctrl,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // حقل إدخال المبلغ المدفوع
                GetX<InvoicePaymentController>(
                  builder: (ctrl) {
                    if (ctrl.paymentType.value == PaymentType.partial) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: TextField(
                          controller: ctrl.paidAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'المبلغ المدفوع',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                            suffixText: 'جنيه',
                          ),
                          onChanged: (value) => ctrl.calculateRemainingAmount(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 24),

                // زر حفظ الفاتورة
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.saveInvoice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'حفظ الفاتورة',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color,
      {bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 18 : 16,
            fontWeight: large ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} جنيه',
          style: TextStyle(
            fontSize: large ? 18 : 16,
            fontWeight: large ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(PaymentType type, String title, IconData icon,
      InvoicePaymentController ctrl) {
    return RadioListTile<PaymentType>(
      title: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      value: type,
      groupValue: ctrl.paymentType.value,
      onChanged: (value) => ctrl.paymentType.value = value!,
      activeColor: Colors.green[700],
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
