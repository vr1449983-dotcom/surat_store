import 'package:sqflite/sqflite.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/product_model.dart';
import '../db/db_helper.dart';
import 'firestore_service.dart';

class SyncService {
  final dbHelper = DBHelper();
  final firestore = FirestoreService();

  // ===========================
  // ⬇️ DOWNLOAD (FIXED)
  // ===========================
  Future<void> downloadAllUserData() async {
    final userId = AuthController.to.currentShopId;
    final db = await dbHelper.db;

    if (userId == null) return;

    final snapshot = await firestore.getUserProducts(userId);

    for (var doc in snapshot.docs) {
      final data = doc.data();

      await db.insert(
        'products',
        {
          'p_id': int.tryParse(doc.id), // 🔥 IMPORTANT
          'shop_id': userId,
          'doc_id': doc.id,
          'name': data['name'],
          'price': data['price'],
          'stock_qty': data['stock_qty'],
          'image_path': data['image_path'] ?? '',
          'description': data['description'] ?? '',
          'is_synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print("✅ Download sync complete (no duplicates)");
  }

  // ===========================
  // 🔄 REALTIME SYNC (FIXED)
  // ===========================
  void startRealtimeSync() {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    firestore.streamProducts(userId).listen((snapshot) async {
      final db = await dbHelper.db;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        await db.insert(
          'products',
          {
            'p_id': int.tryParse(doc.id), // 🔥 IMPORTANT
            'shop_id': userId,
            'doc_id': doc.id,
            'name': data['name'],
            'price': data['price'],
            'stock_qty': data['stock_qty'],
            'image_path': data['image_path'] ?? '',
            'description': data['description'] ?? '',
            'is_synced': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print("🔄 Realtime sync updated (no duplicates)");
    });
  }

  // ===========================
  // ⬆️ UPLOAD (FIXED)
  // ===========================
  Future<void> syncData() async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    if (userId == null) return;

    final products = await db.query(
      'products',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    for (var p in products) {
      final product = ProductModel.fromMap(p);

      final updated =
      await firestore.uploadProduct(userId, product);

      await db.update(
        'products',
        {
          'is_synced': 1,
          'doc_id': updated.docId,
        },
        where: 'p_id = ?',
        whereArgs: [product.pId],
      );
    }

    print("⬆️ Upload sync complete");
  }
}