import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../routes/app_pages.dart';
import '../../services/session_service.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              children: [
                // معلومات المندوب في الأعلى
                Obx(() {
                  if (controller.isDelegate.value) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[700]!, Colors.blue[900]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات المندوب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.inventory_2_outlined,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'عدد القطع المتاحة: ${controller.delegateProducts}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'الرصيد: ${controller.delegateBalance.toStringAsFixed(2)} جنيه',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.isLoading.value)
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              if (!controller.isLoading.value)
                                IconButton(
                                  icon: const Icon(Icons.refresh_outlined),
                                  color: Colors.white70,
                                  onPressed: () =>
                                      controller.loadDelegateInfo(),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // القسم الأول - البطاقات الرئيسية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuCard(
                      context: context,
                      icon: Icons.people,
                      title: 'العملاء',
                      color: Colors.blue,
                      onTap: () => Get.toNamed(Routes.CUSTOMERS_MENU),
                      width: screenWidth * 0.4,
                    ),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.shopping_cart,
                      title: 'المشتريات',
                      color: Colors.green,
                      onTap: () => Get.toNamed(Routes.PURCHASES_MENU),
                      width: screenWidth * 0.4,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuCard(
                      context: context,
                      icon: Icons.play_circle_filled,
                      title: 'بدء الخط',
                      color: Colors.green,
                      onTap: () => Get.toNamed(Routes.START_LINE),
                      width: screenWidth * 0.4,
                      isStartLine: true,
                    ),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.route,
                      title: 'الخطوط',
                      color: Colors.purple,
                      onTap: () => Get.toNamed(Routes.LINES_MENU),
                      width: screenWidth * 0.4,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuCard(
                      context: context,
                      icon: Icons.category,
                      title: 'المنتجات',
                      color: Colors.orange,
                      onTap: () => Get.toNamed(Routes.PRODUCTS_MENU),
                      width: screenWidth * 0.4,
                    ),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.inventory_2_outlined,
                      title: 'المخزن',
                      color: Colors.teal,
                      onTap: () => Get.toNamed(Routes.INVENTORY),
                      width: screenWidth * 0.4,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuCard(
                      context: context,
                      icon: Icons.person_outline,
                      title: 'المناديب',
                      color: Colors.indigo,
                      onTap: () => Get.toNamed(Routes.MANAGE_DELEGATES),
                      width: screenWidth * 0.4,
                    ),
                    if (controller.isAdmin.value)
                      _buildMenuCard(
                        context: context,
                        icon: Icons.admin_panel_settings,
                        title: 'المسؤولين',
                        color: Colors.red,
                        onTap: () => Get.toNamed(Routes.ADMINS_MENU),
                        width: screenWidth * 0.4,
                      ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuCard(
                      context: context,
                      icon: Icons.local_shipping,
                      title: 'تسليم المندوب',
                      color: Colors.indigo,
                      onTap: () => Get.toNamed(Routes.DELEGATE_DELIVERY),
                      width: screenWidth * 0.4,
                      extraIcon: Icons.add_circle,
                      extraIconColor: Colors.indigo,
                    ),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.local_shipping,
                      title: 'الاستلام من المندوب',
                      color: Colors.brown,
                      onTap: () {
                        Get.snackbar(
                          'قريباً',
                          'سيتم إضافة هذه الخاصية قريباً',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      width: screenWidth * 0.4,
                      extraIcon: Icons.attach_money,
                      extraIconColor: Colors.brown,
                      secondExtraIcon: Icons.remove_circle,
                      secondExtraIconColor: Colors.brown,
                      fontSize: 14,
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // إضافة صف جديد لزر المبيعات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuCard(
                      context: context,
                      icon: Icons.point_of_sale,
                      title: 'المبيعات',
                      color: Colors.deepOrange,
                      onTap: () => Get.toNamed(Routes.SALES),
                      width: screenWidth * 0.4,
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.04),

                // زر تسجيل الخروج
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final sessionService = Get.find<SessionService>();
                        sessionService.clearSession();
                        Get.offAllNamed('/login');
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
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

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required double width,
    bool isStartLine = false,
    IconData? extraIcon,
    Color? extraIconColor,
    IconData? secondExtraIcon,
    Color? secondExtraIconColor,
    double? fontSize,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: isStartLine ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isStartLine
              ? BorderSide(color: color.withOpacity(0.5), width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: color,
                      ),
                    ),
                    if (extraIcon != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          extraIcon,
                          size: 16,
                          color: extraIconColor ?? color,
                        ),
                      ),
                    if (secondExtraIcon != null)
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Icon(
                          secondExtraIcon,
                          size: 16,
                          color: secondExtraIconColor ?? color,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize ?? 16,
                    fontWeight:
                        isStartLine ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
