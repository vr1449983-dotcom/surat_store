import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        title: Text(
          "Order ID: ${order.oId}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Date: ${order.orderDate}"),
        trailing: Text(
          "₹${order.totalAmount}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}