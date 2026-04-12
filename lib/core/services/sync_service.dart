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

    print("🔄 Sync Started...");

    try {
      /// 🔥 PRODUCTS
      final products = await db.query(
        'products',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      for (var p in products) {
        try {
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

          print("✅ Product Synced: ${product.name}");
        } catch (e) {
          print("❌ Product Sync Failed: $e");
        }
      }

      /// 🔥 ORDERS
      final orders = await db.query(
        'orders',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      for (var o in orders) {
        try {
          final order = OrderModel.fromMap(o);

          final itemsData = await db.query(
            'order_items',
            where: 'order_id = ?',
            whereArgs: [order.oId],
          );

          final items = itemsData
              .map((e) => OrderItemModel.fromMap(e))
              .toList();

          await firestore.uploadOrderWithItems(
            userId,
            order,
            items,
          );

          await db.update(
            'orders',
            {'is_synced': 1},
            where: 'o_id = ?',
            whereArgs: [order.oId],
          );

          print("✅ Order Synced: ${order.oId}");
        } catch (e) {
          print("❌ Order Sync Failed: $e");
        }
      }

      print("🎉 Sync Completed");
    } catch (e) {
      print("❌ Sync Fatal Error: $e");
    }
  }
}