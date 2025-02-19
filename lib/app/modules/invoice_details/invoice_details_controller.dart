import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InvoiceDetailsController extends GetxController {
  final invoice = Get.arguments['invoice'];

  double get subtotal => (invoice['products'] as List).fold(
      0.0, (sum, product) => sum + (product['price'] * product['quantity']));

  double get totalDiscount => (invoice['products'] as List)
      .fold(0.0, (sum, product) => sum + (product['discount'] ?? 0));

  double get total => invoice['total'];
}
