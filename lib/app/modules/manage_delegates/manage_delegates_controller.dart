import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/session_service.dart';

class ManageDelegatesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = Get.find<SessionService>();
  final isLoading = false.obs;
  final delegates = <DocumentSnapshot>[].obs;
  final searchController = TextEditingController();
  final filteredDelegates = <DocumentSnapshot>[].obs;
  final selectedLine = Rxn<DocumentSnapshot>();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final assignNow = false.obs;
  final assignPermanent = false.obs;
  final lines = <DocumentSnapshot>[].obs;
  final isLoadingLines = false.obs;
  final delegateAssignments = <String, List<DocumentSnapshot>>{}.obs;

  bool get isAdmin => _sessionService.currentUser?['role'] == 'admin';

  @override
  void onInit() {
    super.onInit();
    loadDelegates();
    loadLines();
    loadAllAssignments();
  }

  Future<void> loadDelegates() async {
    try {
      isLoading.value = true;
      final QuerySnapshot result =
          await _firestore.collection('users').orderBy('name').get();

      delegates.value = result.docs;
      filteredDelegates.value = result.docs;

      print('Found ${result.docs.length} users');
      for (var doc in result.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print(
            'User: ${data['name']} - Role: ${data['role']} - Phone: ${data['userNumber']}');
      }
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterDelegates(String query) {
    if (query.isEmpty) {
      filteredDelegates.value = delegates;
      return;
    }

    filteredDelegates.value = delegates.where((delegate) {
      final data = delegate.data() as Map<String, dynamic>;
      final name = data['name'].toString().toLowerCase();
      final phone = data['userNumber'].toString();
      return name.contains(query.toLowerCase()) || phone.contains(query);
    }).toList();
  }

  Future<void> loadLines() async {
    try {
      isLoadingLines.value = true;
      final QuerySnapshot result =
          await _firestore.collection('lines').orderBy('name').get();
      lines.value = result.docs;
    } catch (e) {
      print('Error loading lines: $e');
    } finally {
      isLoadingLines.value = false;
    }
  }

  Future<void> loadAllAssignments() async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('line_assignments')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in result.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final delegateId = data['delegateId'];

        if (!delegateAssignments.containsKey(delegateId)) {
          delegateAssignments[delegateId] = [];
        }
        delegateAssignments[delegateId]!.add(doc);
      }
    } catch (e) {
      print('Error loading assignments: $e');
    }
  }

  Future<void> assignLineToDelegate(String delegateId,
      {String? existingAssignmentId}) async {
    try {
      if (selectedLine.value == null) {
        Get.snackbar(
          'خطأ',
          'برجاء اختيار خط السير',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      final currentAssignments = delegateAssignments[delegateId] ?? [];
      final hasActiveAssignment = currentAssignments.any((assignment) {
        final data = assignment.data() as Map<String, dynamic>;
        return data['lineId'] == selectedLine.value!.id &&
            data['isActive'] == true &&
            assignment.id != existingAssignmentId;
      });

      if (hasActiveAssignment) {
        Get.snackbar(
          'خطأ',
          'هذا المندوب معين بالفعل على هذا الخط',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      final Map<String, dynamic> assignmentData = {
        'lineId': selectedLine.value!.id,
        'lineName':
            (selectedLine.value!.data() as Map<String, dynamic>)['name'],
        'delegateId': delegateId,
        'assignedAt': FieldValue.serverTimestamp(),
        'assignedBy': _sessionService.currentUser!['uid'],
        'isPermanent': assignPermanent.value,
        'isActive': true,
      };

      if (assignPermanent.value) {
        assignmentData['startDate'] = FieldValue.serverTimestamp();
        assignmentData['endDate'] = null;
      } else if (assignNow.value) {
        assignmentData['startDate'] = FieldValue.serverTimestamp();
        assignmentData['endDate'] = Timestamp.fromDate(endDate.value!);
      } else {
        assignmentData['startDate'] = Timestamp.fromDate(startDate.value!);
        assignmentData['endDate'] = Timestamp.fromDate(endDate.value!);
      }

      if (existingAssignmentId != null) {
        await _firestore
            .collection('line_assignments')
            .doc(existingAssignmentId)
            .update(assignmentData);
      } else {
        await _firestore.collection('line_assignments').add(assignmentData);
      }

      delegateAssignments.clear();
      await loadAllAssignments();

      Get.back();
      Get.snackbar(
        'تم بنجاح',
        'تم تعيين خط السير للمندوب',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );

      selectedLine.value = null;
      startDate.value = null;
      endDate.value = null;
      assignNow.value = false;
      assignPermanent.value = false;
    } catch (e) {
      print('Error assigning line: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تعيين خط السير',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> cancelAssignment(String assignmentId) async {
    try {
      await _firestore.collection('line_assignments').doc(assignmentId).update({
        'isActive': false,
        'canceledAt': FieldValue.serverTimestamp(),
        'canceledBy': _sessionService.currentUser!['uid'],
      });

      delegateAssignments.clear();
      await loadAllAssignments();

      Get.snackbar(
        'تم بنجاح',
        'تم إلغاء تعيين الخط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      print('Error canceling assignment: $e');
      Get.snackbar(
        'خطأ',
        'فشل إلغاء تعيين الخط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
