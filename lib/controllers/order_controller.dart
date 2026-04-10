import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../data/models/order_model.dart';
import 'auth_controller.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<OrderModel> orders = <OrderModel>[].obs;

  void startListeningOrders() {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('order_date', descending: true)
        .snapshots()
        .listen((snapshot) {
      orders.value = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  void clearOrders() {
    orders.clear();
  }
}