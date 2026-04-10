import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import 'common_card.dart';


class CartCard extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Row(
        children: [
          Expanded(child: Text(product.name)),

          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onDecrease,
          ),

          Text("$quantity"),

          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrease,
          ),

          Text("₹${product.price * quantity}")
        ],
      ),
    );
  }
}