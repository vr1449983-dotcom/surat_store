import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../core/db/db_helper.dart';
import 'auth_controller.dart';
import 'product_controller.dart';
import '../data/models/product_model.dart';

class CartController extends GetxController {
  var cartItems = <ProductModel, int>{}.obs;

  final dbHelper = DBHelper();
  static const double GST = 0.05;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    if (userId == null) return;

    final data = await db.query(
      'cart',
      where: 'shop_id = ?',
      whereArgs: [userId],
    );

    cartItems.clear();

    for (var item in data) {
      final product = Get.find<ProductController>()
          .products
          .firstWhereOrNull((p) => p.pId == item['product_id']);

      if (product != null) {
        cartItems[product] = item['quantity'] as int;
      }
    }

    cartItems.refresh();
  }

  Future<void> _save(ProductModel product, int qty) async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    await db.insert(
      'cart',
      {
        'shop_id': userId,
        'product_id': product.pId,
        'quantity': qty,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void addToCart(ProductModel product) {
    final qty = (cartItems[product] ?? 0) + 1;

    if (qty > product.stockQty) return;

    cartItems[product] = qty;
    cartItems.refresh();
    _save(product, qty);
  }

  void increase(ProductModel product) => addToCart(product);

  void decrease(ProductModel product) async {
    final qty = (cartItems[product] ?? 0) - 1;

    if (qty <= 0) {
      await remove(product);
      return;
    }

    cartItems[product] = qty;
    cartItems.refresh();
    _save(product, qty);
  }

  Future<void> remove(ProductModel product) async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    cartItems.remove(product);
    cartItems.refresh();

    await db.delete(
      'cart',
      where: 'product_id = ? AND shop_id = ?',
      whereArgs: [product.pId, userId],
    );
  }

  Future<void> clearCart() async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    cartItems.clear();

    await db.delete(
      'cart',
      where: 'shop_id = ?',
      whereArgs: [userId],
    );
  }

  double get total =>
      cartItems.entries.fold(0, (s, e) => s + e.key.price * e.value);

  double get gst => total * GST;

  double get grandTotal => total + gst;
}