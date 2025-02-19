import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'delegate_delivery_form_controller.dart';
import 'widgets/product_card.dart';
import 'widgets/add_product_button.dart';
import 'widgets/total_section.dart';
import 'widgets/save_button.dart';

class DelegateDeliveryFormView extends GetView<DelegateDeliveryFormController> {
  const DelegateDeliveryFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسليم منتجات لـ ${controller.delegateName}'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ),
        ),
        child: Column(
          children: [
            // قائمة المنتجات
            Expanded(
              child: Obx(() {
                if (controller.selectedProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لم يتم إضافة منتجات بعد',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = controller.selectedProducts[index];
                    
                    // إضافة مراقبة للتمرير
                    if (controller.scrollToIndex.value == index) {
                      Scrollable.ensureVisible(
                        context,
                        duration: const Duration(milliseconds: 300),
                        alignment: 0.5,
                      );
                    }
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // معلومات المنتج
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'السعر: ${product.price} جنيه',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'المتاح: ${product.availableQuantity} قطعة',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // حقل الكمية
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                height: 40,
                                child: TextFormField(
                                  key: ValueKey('quantity_${controller.selectedProducts[index].productId}'),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  autofocus: controller.focusQuantityIndex.value == index,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hintText: 'الكمية',
                                    errorStyle: const TextStyle(height: 0),
                                  ),
                                  initialValue: product.quantity.toString(),
                                  onChanged: (value) {
                                    final quantity = int.tryParse(value) ?? 0;
                                    if (quantity <= product.availableQuantity) {
                                      controller.updateQuantity(index, quantity);
                                    } else {
                                      controller.updateQuantity(index, product.availableQuantity);
                                    }
                                  },
                                  validator: (value) {
                                    final quantity = int.tryParse(value ?? '') ?? 0;
                                    if (quantity > product.availableQuantity) {
                                      return '';
                                    }
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                ),
                              ),
                            ),
                            // زر الحذف
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () => controller.removeProduct(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // زر إضافة منتج والإجماليات
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: AddProductButton(
                        onPressed: () => controller.showProductSelection(),
                      ),
                    ),
                    TotalSection(
                      totalQuantity: controller.totalQuantity,
                      totalAmount: controller.totalAmount,
                    ),
                    SaveButton(
                      onPressed: () => controller.saveDelegateDelivery(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 