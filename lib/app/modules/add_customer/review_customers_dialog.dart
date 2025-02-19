import 'package:flutter/material.dart';
import 'add_customer_controller.dart';

class ReviewCustomersDialog extends StatefulWidget {
  final List<CustomerData> customers;
  final Function(List<CustomerData>) onSave;

  const ReviewCustomersDialog({
    Key? key,
    required this.customers,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ReviewCustomersDialog> createState() => _ReviewCustomersDialogState();
}

class _ReviewCustomersDialogState extends State<ReviewCustomersDialog> {
  late List<bool> selectedCustomers;
  late List<CustomerData> editableCustomers;

  @override
  void initState() {
    super.initState();
    selectedCustomers = List.generate(widget.customers.length, (index) => true);
    editableCustomers = List.from(widget.customers);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'مراجعة بيانات العملاء',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: selectedCustomers.every((element) => element),
                onChanged: (value) {
                  setState(() {
                    for (var i = 0; i < selectedCustomers.length; i++) {
                      selectedCustomers[i] = value ?? false;
                    }
                  });
                },
              ),
              const Text('تحديد الكل'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: widget.customers.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: selectedCustomers[index],
                      onChanged: (value) {
                        setState(() {
                          selectedCustomers[index] = value ?? false;
                        });
                      },
                    ),
                    title: TextFormField(
                      initialValue: editableCustomers[index].name,
                      decoration: const InputDecoration(
                        labelText: 'اسم العميل',
                      ),
                      onChanged: (value) {
                        editableCustomers[index] = CustomerData(
                          name: value,
                          phone: editableCustomers[index].phone,
                          nickname: editableCustomers[index].nickname,
                          ovenType: editableCustomers[index].ovenType,
                        );
                      },
                    ),
                    subtitle: Column(
                      children: [
                        TextFormField(
                          initialValue: editableCustomers[index].phone ?? '',
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف',
                          ),
                          onChanged: (value) {
                            editableCustomers[index] = CustomerData(
                              name: editableCustomers[index].name,
                              phone: value,
                              nickname: editableCustomers[index].nickname,
                              ovenType: editableCustomers[index].ovenType,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: editableCustomers[index].nickname ?? '',
                          decoration: const InputDecoration(
                            labelText: 'اللقب',
                          ),
                          onChanged: (value) {
                            editableCustomers[index] = CustomerData(
                              name: editableCustomers[index].name,
                              phone: editableCustomers[index].phone,
                              nickname: value,
                              ovenType: editableCustomers[index].ovenType,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: editableCustomers[index].ovenType ?? '',
                          decoration: const InputDecoration(
                            labelText: 'نوع الفرن',
                          ),
                          onChanged: (value) {
                            editableCustomers[index] = CustomerData(
                              name: editableCustomers[index].name,
                              phone: editableCustomers[index].phone,
                              nickname: editableCustomers[index].nickname,
                              ovenType: value,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final selectedData = editableCustomers
                      .asMap()
                      .entries
                      .where((entry) => selectedCustomers[entry.key])
                      .map((entry) => entry.value)
                      .toList();
                  widget.onSave(selectedData);
                },
                child: const Text('حفظ المحدد'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
