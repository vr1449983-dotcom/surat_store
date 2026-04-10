import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import 'common_card.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("₹${product.price}"),
                Text("Stock: ${product.stockQty}"),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: onAddToCart,
          )
        ],
      ),
    );
  }
}