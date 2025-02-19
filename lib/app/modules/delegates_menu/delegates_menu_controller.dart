import 'package:get/get.dart';
import '../../services/session_service.dart';

class DelegatesMenuController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();

  bool get isAdmin => _sessionService.currentUser?['role'] == 'admin';
}
