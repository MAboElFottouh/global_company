import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class LinesMenuView extends GetView {
  const LinesMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.85;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة خطوط السير'),
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
                Container(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.route_rounded,
                          size: screenHeight * 0.08,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'اختر العملية المطلوبة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.022,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                _buildMenuCard(
                  context: context,
                  icon: Icons.add_road_rounded,
                  title: 'إضافة خط سير جديد',
                  subtitle: 'إضافة خط سير جديد إلى النظام',
                  color: Colors.green,
                  onTap: () => Get.toNamed(Routes.ADD_LINE),
                  width: buttonWidth,
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildMenuCard(
                  context: context,
                  icon: Icons.edit_road_rounded,
                  title: 'تعديل أو حذف خط سير',
                  subtitle: 'تعديل بيانات خطوط السير أو حذفها',
                  color: Colors.orange,
                  onTap: () => Get.toNamed(Routes.MANAGE_LINES),
                  width: buttonWidth,
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildMenuCard(
                  context: context,
                  icon: Icons.reorder_rounded,
                  title: 'تعديل ترتيب خطوط السير',
                  subtitle: 'تغيير ترتيب عرض خطوط السير',
                  color: Colors.blue,
                  onTap: () => Get.toNamed(Routes.REORDER_LINES),
                  width: buttonWidth,
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
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required double width,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: width,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(width * 0.05),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(width * 0.04),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: screenHeight * 0.04,
                    color: color,
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenHeight * 0.022,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: screenHeight * 0.016,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: screenHeight * 0.02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
