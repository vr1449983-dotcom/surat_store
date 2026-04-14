import 'package:sqflite/sqflite.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/product_model.dart';
import '../db/db_helper.dart';
import 'firestore_service.dart';

class SyncService {
  final dbHelper = DBHelper();
  final firestore = FirestoreService();

  // ===========================
  // ⬇️ DOWNLOAD (SAFE + CLEAN)
  // ===========================
  Future<void> downloadAllUserData() async {
    final userId = AuthController.to.currentShopId;
    final db = await dbHelper.db;

    if (userId == null) return;

    final snapshot = await firestore.getUserProducts(userId);

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final pId = int.tryParse(doc.id);
      if (pId == null) continue; // 🔥 prevent crash

      await db.insert(
        'products',
        {
          'p_id': pId,
          'shop_id': userId,
          'doc_id': doc.id,
          'name': data['name'],
          'price': (data['price'] as num).toDouble(),
          'stock_qty': data['stock_qty'],
          'image_path': data['image_path'] ?? '',
          'description': data['description'] ?? '',
          'is_synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print("✅ Download sync complete");
  }

  // ===========================
  // 🔄 REALTIME SYNC (SAFE)
  // ===========================
  void startRealtimeSync() {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    firestore.streamProducts(userId).listen((snapshot) async {
      final db = await dbHelper.db;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final pId = int.tryParse(doc.id);
        if (pId == null) continue;

        await db.insert(
          'products',
          {
            'p_id': pId,
            'shop_id': userId,
            'doc_id': doc.id,
            'name': data['name'],
            'price': (data['price'] as num).toDouble(),
            'stock_qty': data['stock_qty'],
            'image_path': data['image_path'] ?? '',
            'description': data['description'] ?? '',
            'is_synced': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print("🔄 Realtime sync updated");
    });
  }

  // ===========================
  // ⬆️ PRODUCT UPLOAD (SAFE)
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

      /// 🔥 SKIP INVALID
      if (product.pId == null) continue;

      /// 🔥 CHECK EXISTS (prevent ghost re-upload)
      final exists = await db.query(
        'products',
        where: 'p_id = ?',
        whereArgs: [product.pId],
      );

      if (exists.isEmpty) continue;

      try {
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
      } catch (e) {
        print("❌ Product sync failed: $e");
      }
    }

    print("⬆️ Product sync complete");
  }

  // ===========================
  // 🛒 CART SYNC (FINAL 🔥)
  // ===========================
  Future<void> syncCart() async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    if (userId == null) return;

    final items = await db.query(
      'cart',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    for (var item in items) {
      final productId = item['product_id'] as int;
      final qty = item['quantity'] as int;

      /// 🔥 GET PRODUCT
      final productData = await db.query(
        'products',
        where: 'p_id = ?',
        whereArgs: [productId],
      );

      /// ❌ PRODUCT DELETED → REMOVE CART ALSO
      if (productData.isEmpty) {
        await db.delete(
          'cart',
          where: 'product_id = ? AND shop_id = ?',
          whereArgs: [productId, userId],
        );
        continue;
      }

      final product = ProductModel.fromMap(productData.first);

      try {
        /// ☁️ SAVE CART
        await firestore.saveCartItem(userId, product, qty);

        /// ✅ MARK SYNCED
        await db.update(
          'cart',
          {'is_synced': 1},
          where: 'product_id = ? AND shop_id = ?',
          whereArgs: [productId, userId],
        );
      } catch (e) {
        print("❌ Cart sync error: $e");
      }
    }

    print("🛒 Cart sync complete");
  }
}