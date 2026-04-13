import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final int? pId;
  final String? docId;
  final String? shopId;

  final String name;
  final double price;
  final int stockQty;
  final String imagePath;
  final String description;
  final int isSynced;

  ProductModel({
    this.pId,
    this.docId,
    this.shopId,
    required this.name,
    required this.price,
    required this.stockQty,
    required this.imagePath,
    required this.description,
    this.isSynced = 0,
  });

  // ===========================
  // 🔄 COPY WITH
  // ===========================
  ProductModel copyWith({
    int? pId,
    String? docId,
    String? shopId,
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
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      price: price ?? this.price,
      stockQty: stockQty ?? this.stockQty,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // ===========================
  // 📦 SQLITE MAP
  // ===========================
  Map<String, dynamic> toMap() {
    return {
      'p_id': pId,
      'doc_id': docId,
      'shop_id': shopId,
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
      docId: map['doc_id'],
      shopId: map['shop_id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      stockQty: map['stock_qty'],
      imagePath: map['image_path'] ?? '',
      description: map['description'] ?? '',
      isSynced: map['is_synced'] ?? 0,
    );
  }

  // ===========================
  // ☁️ FIRESTORE JSON
  // ===========================
  Map<String, dynamic> toJson() {
    return {
      'p_id': pId,
      'doc_id': docId,
      'shop_id': shopId,
      'name': name,
      'price': price,
      'stock_qty': stockQty,
      'image_path': imagePath,
      'description': description,
      'is_synced': 1,

      /// 🔥 BEST PRACTICE
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  // ===========================
  // ☁️ FROM FIRESTORE
  // ===========================
  factory ProductModel.fromFirestore(
      Map<String, dynamic> map, String docId) {
    return ProductModel(
      docId: docId,
      shopId: map['shop_id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      stockQty: map['stock_qty'],
      imagePath: map['image_path'] ?? '',
      description: map['description'] ?? '',
      isSynced: 1,
    );
  }
}