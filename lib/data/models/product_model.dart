class ProductModel {
  final int? pId;
  final String name;
  final double price;
  final int stockQty;
  final String imagePath;
  final int isSynced;

  ProductModel({
    this.pId,
    required this.name,
    required this.price,
    required this.stockQty,
    required this.imagePath,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'p_id': pId,
      'name': name,
      'price': price,
      'stock_qty': stockQty,
      'image_path': imagePath,
      'is_synced': isSynced,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      pId: map['p_id'],
      name: map['name'],
      price: (map['price'] ?? 0).toDouble(),
      stockQty: map['stock_qty'],
      imagePath: map['image_path'] ?? '',
      isSynced: map['is_synced'] ?? 0,
    );
  }
}