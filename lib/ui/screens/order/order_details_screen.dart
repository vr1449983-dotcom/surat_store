import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final userId = AuthController.to.currentShopId;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      body: SafeArea(
        top: false,
        child: Column(
          children: [

            /// ===========================
            /// 🔥 FLAT MODERN HEADER
            /// ===========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 45,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              color: const Color(0xFF6C5CE7), // flat color (no curve)

              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "Order Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            /// ===========================
            /// 📄 CONTENT
            /// ===========================
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('orders')
                    .doc(orderId)
                    .collection('items')
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No items found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final items = snapshot.data!.docs;

                  double total = 0;
                  for (var item in items) {
                    final data = item.data();
                    total += (data['price'] ?? 0) * (data['qty'] ?? 0);
                  }

                  return Column(
                    children: [

                      /// 🛍 ITEMS LIST
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final data = items[index].data();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              child: Row(
                                children: [

                                  /// ICON
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C5CE7).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag,
                                      size: 18,
                                      color: Color(0xFF6C5CE7),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  /// DETAILS
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['product_name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Qty: ${data['qty']}",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// PRICE
                                  Text(
                                    "₹${data['price']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      /// ===========================
                      /// 💰 BOTTOM TOTAL BAR (MODERN)
                      /// ===========================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${items.length} items",
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              "₹${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}