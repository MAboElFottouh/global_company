import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_service.dart';
import '../../routes/app_pages.dart';

class StartLineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = Get.find<SessionService>();

  final isLoading = false.obs;
  final lines = <DocumentSnapshot<Map<String, dynamic>>>[].obs;

  bool get isAdmin => _sessionService.currentUser?['role'
  ] == 'admin';

  @override
  void onInit() {
    super.onInit();
    if (isAdmin) {
      loadAllLines();
    } else {
      loadAssignedLines();
    }
  }

  Future<void> loadAllLines() async {
    try {
      isLoading.value = true;
      final QuerySnapshot<Map<String, dynamic>> result =
          await _firestore.collection('lines').orderBy('name').get();
      lines.value = result.docs;
    } catch (e) {
      print('Error loading all lines: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAssignedLines() async {
    try {
      isLoading.value = true;

      final userId = _sessionService.currentUser!['uid'
      ];
      final QuerySnapshot<Map<String, dynamic>> result = await _firestore
          .collection('line_assignments')
          .where('delegateId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      lines.clear();
      for (var doc in result.docs) {
        final lineData = doc.data();
        final lineDoc =
            await _firestore.collection('lines').doc(lineData['lineId'
        ]).get();
        if (lineDoc.exists) {
          lines.add(lineDoc);
        }
      }
    } catch (e) {
      print('Error loading assigned lines: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startLine(DocumentSnapshot<Map<String, dynamic>> line) async {
    try {
      // هنا يمكنك إضافة المنطق الخاص ببدء الخط
      final lineData = line.data()!;
      Get.snackbar(
        'نجاح',
        'تم بدء العمل على خط ${lineData['name'
        ]
      }',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[
        100
      ],
        colorText: Colors.green[
        900
      ],
      );
    } catch (e) {
      print('Error starting line: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء بدء الخط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[
        100
      ],
        colorText: Colors.red[
        900
      ],
      );
    }
  }

  void showLineCustomers(DocumentSnapshot<Map<String, dynamic>> line) {
    final lineData = line.data()!;
    Get.toNamed(
      Routes.LINE_CUSTOMERS,
      arguments: {
        'lineData': lineData,
        'lineId': line.id,
    },
    );
  }
}