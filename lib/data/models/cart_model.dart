class CartModel {
  final int? id;
  final String shopId;
  final int productId;
  final String name;
  final double price;
  final int qty;
  final int stockQty;
  final String imagePath;

  CartModel({
    this.id,
    required this.shopId,
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
    required this.stockQty,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_id': shopId,
      'product_id': productId,
      'name': name,
      'price': price,
      'qty': qty,
      'stock_qty': stockQty,
      'image_path': imagePath,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'],
      shopId: map['shop_id'],
      productId: map['product_id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      qty: map['qty'],
      stockQty: map['stock_qty'],
      imagePath: map['image_path'] ?? '',
    );
  }
}