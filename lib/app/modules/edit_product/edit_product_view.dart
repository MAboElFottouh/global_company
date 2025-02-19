import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_product_controller.dart';
import 'package:flutter/services.dart';

class EditProductView extends GetView<EditProductController> {
  const EditProductView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات المنتج'),
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
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.edit_note,
                  size: screenHeight * 0.1,
                  color: Colors.green,
                ),
                SizedBox(height: screenHeight * 0.02),

                // عرض رقم المنتج
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'رقم المنتج',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.productData['productId'] ?? 'غير محدد',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'تعديل بيانات المنتج',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.026,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // اسم المنتج
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المنتج',
                    prefixIcon: const Icon(Icons.inventory),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // سعر المنتج
                TextField(
                  controller: controller.priceController,
                  decoration: InputDecoration(
                    labelText: 'سعر المنتج',
                    prefixIcon: const Icon(Icons.attach_money),
                    suffixText: 'جنيه',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (value) => controller.updatePackagePrice(),
                ),
                SizedBox(height: screenHeight * 0.02),

                // خيار البيع بالتجزئة
                Obx(() => CheckboxListTile(
                      title: const Text('يمكن بيع جزء من المنتج'),
                      subtitle:
                          const Text('مثال: نصف كرتونة، ربع كرتونة، باكو'),
                      value: controller.canSellPackages.value,
                      onChanged: (value) {
                        controller.canSellPackages.value = value ?? false;
                        controller.updatePackagePrice();
                      },
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )),

                // عدد الأجزاء في المنتج
                Obx(() => controller.canSellPackages.value
                    ? Column(
                        children: [
                          TextField(
                            controller: controller.packagesCountController,
                            decoration: InputDecoration(
                              labelText: 'عدد الأجزاء في المنتج',
                              hintText: 'مثال: عدد البواكي في الكرتونة',
                              prefixIcon: const Icon(Icons.inventory_2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) =>
                                controller.updatePackagePrice(),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // عرض سعر الجزء
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'سعر الجزء الواحد: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Obx(() => Text(
                                      '${controller.packagePrice.value.toStringAsFixed(2)} جنيه',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox()),

                SizedBox(height: screenHeight * 0.04),

                // زر الحفظ
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.updateProduct(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'حفظ التغييرات',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
