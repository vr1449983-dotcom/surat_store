class OrderItemModel {
  final int? id;
  final String orderId;
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

  Map<String, dynamic> toMap() {
    return {
      'item_id': id,
      'order_id': orderId,
      'product_id': null,
      'qty_sold': qty,
      'price_at_sale': price,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['item_id'],
      orderId: map['order_id'],
      productName: map['product_name'] ?? '',
      price: (map['price_at_sale'] ?? 0).toDouble(),
      qty: map['qty_sold'] ?? 0,
    );
  }
}