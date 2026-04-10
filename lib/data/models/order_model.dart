class OrderModel {
  final String oId;
  final double totalAmount;
  final String orderDate;
  final int isSynced;

  OrderModel({
    required this.oId,
    required this.totalAmount,
    required this.orderDate,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'o_id': oId,
      'total_amount': totalAmount,
      'order_date': orderDate,
      'is_synced': isSynced,
    };
  }

  // 🔥 FIXED: supports BOTH SQLite & Firestore
  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return OrderModel(
      oId: docId ?? map['o_id'], // 🔥 important fix
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      orderDate: map['order_date'] ?? '',
      isSynced: map['is_synced'] ?? 0,
    );
  }
}