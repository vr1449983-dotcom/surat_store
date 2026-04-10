import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadProduct(String userId, ProductModel product) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .add(product.toMap());
  }

  Future<void> uploadOrder(String userId, OrderModel order) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(order.oId)
        .set(order.toMap());
  }
}