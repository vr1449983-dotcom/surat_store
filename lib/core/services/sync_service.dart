import '../../controllers/auth_controller.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_item_model.dart';
import '../db/db_helper.dart';
import 'firestore_service.dart';

class SyncService {
  final dbHelper = DBHelper();
  final firestore = FirestoreService();

  Future<void> syncData() async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    if (userId == null) return;

    try {
      // =========================
      // 🔥 1. SYNC PRODUCTS
      // =========================
      final products = await db.query(
        'products',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      for (var p in products) {
        final product = ProductModel.fromMap(p);

        await firestore.uploadProduct(userId, product);

        await db.update(
          'products',
          {'is_synced': 1},
          where: 'p_id = ?',
          whereArgs: [p['p_id']],
        );
      }

      // =========================
      // 🔥 2. SYNC ORDERS + ITEMS
      // =========================
      final orders = await db.query(
        'orders',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      for (var o in orders) {
        final order = OrderModel.fromMap(o);

        // 🔥 GET ITEMS FROM LOCAL DB
        final itemsData = await db.query(
          'order_items',
          where: 'order_id = ?',
          whereArgs: [order.oId],
        );

        final items = itemsData
            .map((e) => OrderItemModel.fromMap(e))
            .toList();

        // 🔥 UPLOAD ORDER + ITEMS (ATOMIC)
        await firestore.uploadOrderWithItems(
          userId,
          order,
          items,
        );

        // ✅ MARK ORDER AS SYNCED
        await db.update(
          'orders',
          {'is_synced': 1},
          where: 'o_id = ?',
          whereArgs: [order.oId],
        );
      }
    } catch (e) {
      print("❌ Sync Error: $e");
    }
  }
}