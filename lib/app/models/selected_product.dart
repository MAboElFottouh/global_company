class SelectedProduct {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final int availableQuantity;

  SelectedProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.availableQuantity,
  });

  double get total => quantity * price;
} 