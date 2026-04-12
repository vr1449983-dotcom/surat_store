import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

class FirestoreService {
  /// ✅ Lazy getter (IMPORTANT FIX)
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ===========================
  // 📦 PRODUCT SYNC
  // ===========================
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

  // ===========================
  // 🧾 ORDER + ITEMS
  // ===========================
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

    batch.set(orderRef, order.toMap(), SetOptions(merge: true));

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
}