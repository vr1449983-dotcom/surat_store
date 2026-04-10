import '../../controllers/auth_controller.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../db/db_helper.dart';
import 'firestore_service.dart';


class SyncService {
  final dbHelper = DBHelper();
  final firestore = FirestoreService();

  Future<void> syncData() async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    if (userId == null) return;

    // Sync Products
    final products = await db.query('products', where: 'is_synced = ?', whereArgs: [0]);

    for (var product in products) {
      await firestore.uploadProduct(userId, ProductModel.fromMap(product));

      await db.update(
        'products',
        {'is_synced': 1},
        where: 'p_id = ?',
        whereArgs: [product['p_id']],
      );
    }

    // Sync Orders
    final orders = await db.query('orders', where: 'is_synced = ?', whereArgs: [0]);

    for (var order in orders) {
      await firestore.uploadOrder(userId, OrderModel.fromMap(order));

      await db.update(
        'orders',
        {'is_synced': 1},
        where: 'o_id = ?',
        whereArgs: [order['o_id']],
      );
    }
  }
}