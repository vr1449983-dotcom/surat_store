import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import 'common_card.dart';

class CartCard extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMin = quantity <= 1;
    final isMax = quantity >= product.stockQty;

    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            /// 🛍 PRODUCT INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "₹${product.price}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  /// 🔴 STOCK WARNING
                  if (isMax)
                    const Text(
                      "Max stock reached",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            /// 🔢 QTY CONTROLS
            Row(
              children: [
                IconButton(
                  onPressed: isMin ? null : onDecrease,
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: isMin ? Colors.grey : null,
                  ),
                ),

                Text(
                  "$quantity",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                IconButton(
                  onPressed: isMax ? null : onIncrease,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: isMax ? Colors.grey : null,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 10),

            /// 💰 PRICE
            Text(
              "₹${(product.price * quantity).toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            /// ❌ REMOVE BUTTON
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}