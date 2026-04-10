class ProductModel {
  final int? pId;
  final String? docId;
  final String name;
  final double price;
  final int stockQty;
  final String imagePath;
  final String description;
  final int isSynced;

  ProductModel({
    this.pId,
    this.docId,
    required this.name,
    required this.price,
    required this.stockQty,
    required this.imagePath,
    required this.description,
    this.isSynced = 0,
  });

  // ✅ FOR SQLITE + FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'p_id': pId,
      'doc_id': docId, // 🔥 IMPORTANT
      'name': name,
      'price': price,
      'stock_qty': stockQty,
      'image_path': imagePath,
      'description': description,
      'is_synced': isSynced,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      pId: map['p_id'],
      docId: map['doc_id'], // 🔥 IMPORTANT
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stockQty: map['stock_qty'] ?? 0,
      imagePath: map['image_path'] ?? '',
      description: map['description'] ?? '',
      isSynced: map['is_synced'] ?? 0,
    );
  }
}