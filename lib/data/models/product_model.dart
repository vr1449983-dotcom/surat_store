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

  // ===========================
  // 🔁 COPY WITH (IMPORTANT)
  // ===========================
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

  // ===========================
  // 📦 TO MAP (SQLite)
  // ===========================
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'doc_id': docId,
      'name': name,
      'price': price,
      'stock_qty': stockQty,
      'image_path': imagePath,
      'description': description,
      'is_synced': isSynced,
    };

    // ✅ only include ID if exists (important for insert)
    if (pId != null) {
      map['p_id'] = pId;
    }

    return map;
  }

  // ===========================
  // 📥 FROM MAP (SQLite)
  // ===========================
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      pId: map['p_id'] as int?,
      docId: map['doc_id'] as String?,
      name: map['name']?.toString() ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
      stockQty: map['stock_qty'] ?? 0,
      imagePath: map['image_path']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      isSynced: map['is_synced'] ?? 0,
    );
  }

  // ===========================
  // ☁️ TO JSON (Firebase)
  // ===========================
  Map<String, dynamic> toJson() {
    return {
      'doc_id': docId,
      'name': name,
      'price': price,
      'stock_qty': stockQty,
      'image_path': imagePath,
      'description': description,
      'is_synced': isSynced,
    };
  }

  // ===========================
  // ☁️ FROM JSON (Firebase)
  // ===========================
  factory ProductModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return ProductModel(
      docId: docId ?? json['doc_id'],
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockQty: json['stock_qty'] ?? 0,
      imagePath: json['image_path'] ?? '',
      description: json['description'] ?? '',
      isSynced: json['is_synced'] ?? 1,
    );
  }
}