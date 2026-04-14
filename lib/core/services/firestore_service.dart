import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

class FirestoreService {
  /// ✅ Lazy instance
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // =========================================================
  // 📦 PRODUCT SYNC (🔥 FIXED - NO DUPLICATES)
  // =========================================================

  Future<ProductModel> uploadProduct(
      String userId, ProductModel product) async {

    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('products');

    /// 🔥 MUST HAVE p_id
    if (product.pId == null) {
      throw Exception("❌ p_id is null. Cannot sync product.");
    }

    /// 🔥 USE FIXED DOC ID (VERY IMPORTANT)
    final docId = product.docId != null && product.docId!.isNotEmpty
        ? product.docId!
        : product.pId.toString();

    final docRef = collection.doc(docId);

    await docRef.set(
      product.toJson(),
      SetOptions(merge: true), // ✅ update only
    );

    return product.copyWith(
      docId: docRef.id,
      isSynced: 1,
    );
  }

  // =========================================================
  // ❌ DELETE PRODUCT
  // =========================================================

  Future<void> deleteProduct(String userId, String docId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(docId)
        .delete();
  }

  // =========================================================
  // 🔄 UPDATE STOCK (AFTER ORDER)
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
    });
  }

  // =========================================================
  // 🧾 ORDER + ITEMS
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
  // 🛒 CART SYNC
  // =========================================================

  Future<void> saveCartItem(
      String userId, ProductModel product, int qty) async {

    if (product.pId == null) return;

    await _firestore
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

  Future<QuerySnapshot<Map<String, dynamic>>> getCart(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();
  }

  Future<void> removeCartItem(String userId, int productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId.toString())
        .delete();
  }

  Future<void> clearCart(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
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
  // 📡 STREAM ORDERS
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