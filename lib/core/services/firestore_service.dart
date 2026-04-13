import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

class FirestoreService {
  /// ✅ Lazy instance
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // =========================================================
  // 📦 PRODUCT SYNC
  // =========================================================

  Future<ProductModel> uploadProduct(
      String userId, ProductModel product) async {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('products');

    DocumentReference docRef;

    if (product.docId != null && product.docId!.isNotEmpty) {
      docRef = collection.doc(product.docId);
      await docRef.set(product.toJson(), SetOptions(merge: true));
    } else {
      docRef = await collection.add(product.toJson());
    }

    return product.copyWith(
      docId: docRef.id,
      isSynced: 1,
    );
  }

  /// ❌ DELETE PRODUCT
  Future<void> deleteProduct(String userId, String docId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(docId)
        .delete();
  }

  /// 🔄 UPDATE STOCK (USED AFTER ORDER)
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
  // 🛒 CART SYNC (🔥 NEW)
  // =========================================================

  /// 📤 SAVE CART ITEM
  Future<void> saveCartItem(
      String userId, ProductModel product, int qty) async {
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

  /// 📥 GET CART (FOR MULTI DEVICE)
  Future<QuerySnapshot<Map<String, dynamic>>> getCart(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();
  }

  /// ❌ REMOVE CART ITEM
  Future<void> removeCartItem(String userId, int productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId.toString())
        .delete();
  }

  /// 🧹 CLEAR FULL CART
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
  // 📡 FETCH / STREAM PRODUCTS
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
  // 📡 STREAM ORDERS (OPTIONAL)
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