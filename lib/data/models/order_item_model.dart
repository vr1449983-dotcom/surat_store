class OrderItemModel {
  final int? id; // local DB id
  final String orderId; // 🔥 link to order
  final String productName;
  final double price;
  final int qty;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.productName,
    required this.price,
    required this.qty,
  });

  // 🔥 SQLITE + FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_name': productName,
      'price': price,
      'qty': qty,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'],
      orderId: map['order_id'],
      productName: map['product_name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      qty: map['qty'] ?? 0,
    );
  }
}