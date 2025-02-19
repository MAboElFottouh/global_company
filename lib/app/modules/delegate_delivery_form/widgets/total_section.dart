import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TotalSection extends StatelessWidget {
  final RxInt totalQuantity;
  final RxDouble totalAmount;

  const TotalSection({
    Key? key,
    required this.totalQuantity,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          top: BorderSide(
            color: Colors.blue[100]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إجمالي القطع:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                    '${totalQuantity.value} قطعة',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  )),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'الإجمالي:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                    '${totalAmount.value.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
} 