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

  ProductModel copyWith({
    int? pId,
    String? docId,
    String? name,
    double? price,
    int? stockQty,
    String? imagePath,
    String? description,
    int? isSynced,
  }) {
    return ProductModel(
      pId: pId ?? this.pId,
      docId: docId ?? this.docId,
      name: name ?? this.name,
      price: price ?? this.price,
      stockQty: stockQty ?? this.stockQty,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'doc_id': docId,
      'name': name,
      'price': price,
      'stock_qty': stockQty,
      'image_path': imagePath,
      'description': description,
      'is_synced': isSynced,
    };

    if (pId != null) {
      map['p_id'] = pId;
    }

    return map;
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      pId: map['p_id'],
      docId: map['doc_id'],
      name: map['name'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
      stockQty: map['stock_qty'] ?? 0,
      imagePath: map['image_path'] ?? '',
      description: map['description'] ?? '',
      isSynced: map['is_synced'] ?? 0,
    );
  }

  /// 🔥 CLEAN FIRESTORE JSON (NO LOCAL FIELDS)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'stock_qty': stockQty,
      'image_path': imagePath,
      'description': description,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return ProductModel(
      docId: docId,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockQty: json['stock_qty'] ?? 0,
      imagePath: json['image_path'] ?? '',
      description: json['description'] ?? '',
      isSynced: 1,
    );
  }
}