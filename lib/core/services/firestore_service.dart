import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProductModel> uploadProduct(
      String userId, ProductModel product) async {

    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .add(product.toMap());

    return ProductModel(
      pId: product.pId,
      docId: docRef.id,
      name: product.name,
      price: product.price,
      stockQty: product.stockQty,
      imagePath: product.imagePath,
      description: product.description,
      isSynced: 1,
    );
  }
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

    // ✅ ORDER
    batch.set(orderRef, order.toMap());

    // ✅ ITEMS SUBCOLLECTION
    for (var item in items) {
      final itemRef = orderRef.collection('items').doc();

      batch.set(itemRef, {
        'product_name': item.productName,
        'price': item.price,
        'qty': item.qty,
      });
    }

    await batch.commit();
  }
}