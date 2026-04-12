import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================
  // 📦 PRODUCT SYNC (SMART)
  // ===========================
  Future<ProductModel> uploadProduct(
      String userId, ProductModel product) async {
    try {
      final collection = _firestore
          .collection('users')
          .doc(userId)
          .collection('products');

      DocumentReference docRef;

      // 🔥 UPDATE if docId exists
      if (product.docId != null && product.docId!.isNotEmpty) {
        docRef = collection.doc(product.docId);

        await docRef.set(product.toJson(), SetOptions(merge: true));
      } else {
        // 🔥 CREATE new
        docRef = await collection.add(product.toJson());
      }

      return product.copyWith(
        docId: docRef.id,
        isSynced: 1,
      );
    } catch (e) {
      print("❌ FIRESTORE PRODUCT ERROR: $e");
      rethrow;
    }
  }

  // ===========================
  // 🧾 ORDER + ITEMS (BATCH)
  // ===========================
  Future<void> uploadOrderWithItems(
      String userId,
      OrderModel order,
      List<OrderItemModel> items,
      ) async {
    try {
      final orderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(order.oId);

      final batch = _firestore.batch();

      // ✅ ORDER
      batch.set(orderRef, order.toMap(), SetOptions(merge: true));

      // ✅ ITEMS
      for (var item in items) {
        final itemRef = orderRef.collection('items').doc();

        batch.set(itemRef, {
          'product_name': item.productName,
          'price': item.price,
          'qty': item.qty,
        });
      }

      await batch.commit();
    } catch (e) {
      print("❌ FIRESTORE ORDER ERROR: $e");
      rethrow;
    }
  }
}