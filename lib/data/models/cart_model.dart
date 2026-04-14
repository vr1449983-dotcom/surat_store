class CartItemModel {
  final int productId;
  final int quantity;
  final int isSynced;

  CartItemModel({
    required this.productId,
    required this.quantity,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap(String shopId) {
    return {
      'shop_id': shopId,
      'product_id': productId,
      'quantity': quantity,
      'is_synced': isSynced,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['product_id'],
      quantity: map['quantity'],
      isSynced: map['is_synced'] ?? 0,
    );
  }
}