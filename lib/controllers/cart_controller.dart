import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/db/db_helper.dart';
import 'auth_controller.dart';
import 'product_controller.dart';
import '../data/models/product_model.dart';

class CartController extends GetxController {
  var cartItems = <ProductModel, int>{}.obs;

  final dbHelper = DBHelper();
  final firestore = FirebaseFirestore.instance;

  static const double GST = 0.05;

  @override
  void onInit() {
    super.onInit();

    loadCart();

    /// 🔥 AUTO REFRESH WHEN PRODUCTS CHANGE
    ever(Get.find<ProductController>().products, (_) {
      loadCart();
    });
  }

  // ===========================
  // 🔄 LOAD CART (LOCAL + CLOUD)
  // ===========================
  Future<void> loadCart() async {
    await _loadLocalCart();
    await _syncFromCloud();
  }

  // ===========================
  // 📦 LOCAL LOAD (FIXED)
  // ===========================
  Future<void> _loadLocalCart() async {
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
      } else {
        /// 🔥 REMOVE INVALID LOCAL ITEM
        await db.delete(
          'cart',
          where: 'product_id = ? AND shop_id = ?',
          whereArgs: [item['product_id'], userId],
        );
      }
    }

    cartItems.refresh();
  }

  // ===========================
  // ☁️ FIRESTORE SYNC (FIXED)
  // ===========================
  Future<void> _syncFromCloud() async {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in snapshot.docs) {
      final productId = int.tryParse(doc.id);
      final qty = doc['quantity'] ?? 0;

      if (productId == null) continue;

      final product = Get.find<ProductController>()
          .products
          .firstWhereOrNull((p) => p.pId == productId);

      if (product != null) {
        cartItems[product] = qty;

        /// 🔄 KEEP LOCAL IN SYNC
        await _saveLocal(product, qty);
      } else {
        /// 🔥 REMOVE INVALID CLOUD ITEM
        await doc.reference.delete();
      }
    }

    cartItems.refresh();
  }

  // ===========================
  // 💾 SAVE LOCAL
  // ===========================
  Future<void> _saveLocal(ProductModel product, int qty) async {
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

  // ===========================
  // ☁️ SAVE CLOUD
  // ===========================
  Future<void> _saveCloud(ProductModel product, int qty) async {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(product.pId.toString())
        .set({
      'product_id': product.pId,
      'quantity': qty,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ===========================
  // ➕ ADD / UPDATE
  // ===========================
  void addToCart(ProductModel product) async {
    final qty = (cartItems[product] ?? 0) + 1;

    if (qty > product.stockQty) {
      Get.snackbar("Stock Limit", "Max stock reached");
      return;
    }

    cartItems[product] = qty;
    cartItems.refresh();

    await _saveLocal(product, qty);
    await _saveCloud(product, qty);
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

    await _saveLocal(product, qty);
    await _saveCloud(product, qty);
  }

  // ===========================
  // ❌ REMOVE SINGLE ITEM
  // ===========================
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

    await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(product.pId.toString())
        .delete();
  }

  // ===========================
  // 🔥 REMOVE BY PRODUCT ID (CRITICAL FIX)
  // ===========================
  void removeProductById(int productId) {
    cartItems.removeWhere((product, qty) => product.pId == productId);
    cartItems.refresh();
  }

  // ===========================
  // 🧹 CLEAR CART
  // ===========================
  Future<void> clearCart() async {
    final db = await dbHelper.db;
    final userId = AuthController.to.currentShopId;

    /// 🔥 FORCE CLEAR MEMORY FIRST
    cartItems.clear();
    cartItems.refresh();

    /// 🔥 DELETE LOCAL
    await db.delete(
      'cart',
      where: 'shop_id = ?',
      whereArgs: [userId],
    );

    /// 🔥 DELETE CLOUD
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    /// 🔥 FINAL REFRESH (IMPORTANT)
    cartItems.clear();
    cartItems.refresh();
  }

  // ===========================
  // 💰 TOTALS
  // ===========================
  double get total =>
      cartItems.entries.fold(0, (s, e) => s + e.key.price * e.value);

  double get gst => total * GST;

  double get grandTotal => total + gst;
}