import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controllers/auth_controller.dart';


class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final userId = AuthController.to.currentShopId;

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(orderId)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text("No items"));
          }

          return ListView(
            children: items.map((item) {
              final data = item.data();
              return ListTile(
                title: Text(data['product_name']),
                subtitle: Text("Qty: ${data['qty']}"),
                trailing: Text("₹${data['price']}"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}