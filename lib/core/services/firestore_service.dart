import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

class FirestoreService {
  /// ✅ Singleton
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // =========================================================
  // 📦 PRODUCT SYNC (NO DUPLICATES 🔥)
  // =========================================================

  Future<ProductModel> uploadProduct(
      String userId, ProductModel product) async {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('products');

    if (product.pId == null) {
      throw Exception("❌ p_id is null. Cannot sync product.");
    }

    /// 🔥 FIXED DOC ID
    final docId = (product.docId != null && product.docId!.isNotEmpty)
        ? product.docId!
        : product.pId.toString();

    final docRef = collection.doc(docId);

    await docRef.set(
      product.toJson(),
      SetOptions(merge: true),
    );

    return product.copyWith(
      docId: docRef.id,
      isSynced: 1,
    );
  }

  // =========================================================
  // ❌ DELETE PRODUCT (FULL DELETE 🔥)
  // =========================================================

  Future<void> deleteProduct(String userId, String docId) async {
    final batch = _firestore.batch();

    final productRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(docId);

    /// 🔥 DELETE PRODUCT
    batch.delete(productRef);

    /// 🔥 DELETE FROM CART ALSO (IMPORTANT)
    final cartRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(docId);

    batch.delete(cartRef);

    await batch.commit();
  }

  // =========================================================
  // 🔄 UPDATE STOCK
  // =========================================================

  Future<void> updateProductStock(
      String userId, String docId, int qty) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(docId)
        .update({
      'stock_qty': FieldValue.increment(-qty),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // 🧾 ORDER + ITEMS (BATCH 🔥)
  // =========================================================

  Future<void> uploadOrderWithItems(
      String userId,
      OrderModel order,
      List<OrderItemModel> items,
      ) async {
    final orderRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(order.oId);

    final batch = _firestore.batch();

    /// 📦 ORDER
    batch.set(orderRef, order.toMap(), SetOptions(merge: true));

    /// 📦 ITEMS
    for (var item in items) {
      final itemRef = orderRef.collection('items').doc();

      batch.set(itemRef, {
        'product_name': item.productName,
        'qty_sold': item.qty,
        'price_at_sale': item.price,
      });
    }

    await batch.commit();
  }

  // =========================================================
  // 🛒 CART SYSTEM (🔥 PERFECT)
  // =========================================================

  /// ➕ ADD / UPDATE
  Future<void> saveCartItem(
      String userId, ProductModel product, int qty) async {
    if (product.pId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(product.pId.toString());

    await docRef.set({
      'product_id': product.pId,
      'quantity': qty,
      'price': product.price,
      'name': product.name,
      'image_path': product.imagePath,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // 🔥 IMPORTANT
  }

  /// ❌ REMOVE ITEM
  Future<void> removeCartItem(String userId, int productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId.toString())
        .delete();
  }

  /// 🧹 CLEAR CART (FAST 🔥)
  Future<void> clearCart(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// 📥 GET CART
  Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    return snapshot.docs.map((e) => e.data()).toList();
  }

  /// 📡 REALTIME CART
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCart(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .orderBy('updated_at', descending: true)
        .snapshots();
  }

  /// 🔄 FULL CART SYNC (OFFLINE → ONLINE)
  Future<void> syncFullCart(
      String userId, Map<ProductModel, int> cartItems) async {
    final batch = _firestore.batch();

    for (var entry in cartItems.entries) {
      final product = entry.key;
      final qty = entry.value;

      if (product.pId == null) continue;

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(product.pId.toString());

      batch.set(docRef, {
        'product_id': product.pId,
        'quantity': qty,
        'price': product.price,
        'name': product.name,
        'image_path': product.imagePath,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  // =========================================================
  // 📡 PRODUCTS FETCH / STREAM
  // =========================================================

  Future<QuerySnapshot<Map<String, dynamic>>> getUserProducts(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProducts(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .snapshots();
  }

  // =========================================================
  // 📡 ORDERS STREAM
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> streamOrders(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('order_date', descending: true)
        .snapshots();
  }
}