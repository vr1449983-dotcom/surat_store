import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/buy_now_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/db/db_helper.dart';
import '../../../core/services/sync_manager.dart';

class BuyNowCheckoutScreen extends StatelessWidget {
  const BuyNowCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buyNow = Get.find<BuyNowController>();
    final auth = AuthController.to;

    final nameController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Checkout",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C5CE7),
      ),

      resizeToAvoidBottomInset: true,

      body: Obx(() {
        final product = buyNow.product.value;

        if (product == null) {
          return const Center(child: Text("No product"));
        }

        return Column(
          children: [

            /// 🔽 SCROLL CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// PRODUCT CARD
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_bag, size: 45),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(product.name,
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text("₹${product.price}",
                                    style: const TextStyle(
                                        color: Colors.green)),
                                Text("Stock: ${product.stockQty}",
                                    style: TextStyle(
                                        color:
                                        Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// CUSTOMER NAME
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Customer Name *",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// SECTION TITLE
                    const Text(
                      "Add Quantity",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// QTY CONTROL
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                        child: Obx(() =>
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed:
                                  buyNow.quantity.value <= 1
                                      ? null
                                      : buyNow.decreaseQty,
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  "${buyNow.quantity.value}",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: buyNow.quantity.value >=
                                      product.stockQty
                                      ? null
                                      : buyNow.increaseQty,
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            )),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            /// 🔥 BOTTOM ONLY SAFE AREA
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    _row("Subtotal", buyNow.total),
                    _row("GST", buyNow.gst),

                    const Divider(),

                    _row("Total", buyNow.grandTotal,
                        bold: true),

                    const SizedBox(height: 12),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: product.stockQty == 0
                            ? null
                            : () async {
                          final name =
                          nameController.text.trim();

                          if (name.isEmpty) {
                            Get.snackbar(
                                "Error",
                                "Customer name required");
                            return;
                          }

                          await _placeOrder(
                              buyNow, auth, name);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Place Order",
                          style: TextStyle(
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _row(String title, double value,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight:
              bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// 🚀 ORDER FLOW (FINAL FIXED)
  /// ===============================
  Future<void> _placeOrder(BuyNowController buyNow,
      AuthController auth,
      String customerName) async {
    final product = buyNow.product.value!;
    final qty = buyNow.quantity.value;

    final db = await DBHelper().db;
    final orderId =
    DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    try {
      /// LOCAL SAVE
      await db.insert('orders', {
        'o_id': orderId,
        'customer_name': customerName,
        'total_amount': buyNow.grandTotal,
        'order_date': DateTime.now().toString(),
        'is_synced': 0,
      });

      await db.insert('order_items', {
        'order_id': orderId,
        'product_id': product.pId,
        'qty_sold': qty,
        'price_at_sale': product.price,
      });

      await db.update(
        'products',
        {
          'stock_qty': product.stockQty - qty,
          'is_synced': 0,
        },
        where: 'p_id = ?',
        whereArgs: [product.pId],
      );

      await Get.find<ProductController>()
          .loadProducts();

      SyncManager().scheduleSync();

      final hasInternet = await _hasInternet();

      if (hasInternet) {
        await _syncToCloud(
            orderId, buyNow, auth, product, qty,
            customerName);
      }

      _showResultDialog(isOnline: hasInternet);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// INTERNET CHECK
  Future<bool> _hasInternet() async {
    try {
      final result =
      await InternetAddress.lookup('google.com');
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// CLOUD SYNC
  Future<void> _syncToCloud(String orderId,
      BuyNowController buyNow,
      AuthController auth,
      product,
      int qty,
      String customerName) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final orderRef = firestore
          .collection('users')
          .doc(auth.currentShopId)
          .collection('orders')
          .doc(orderId);

      await orderRef.set({
        'customer_name': customerName,
        'total_amount': buyNow.grandTotal,
        'order_date': DateTime.now().toString(),
        'is_synced': 1,
      });

      await orderRef.collection('items').add({
        'product_name': product.name,
        'qty': qty,
        'price': product.price,
      });
    } catch (_) {}
  }

  /// SUCCESS DIALOG (PRO UI)
  void _showResultDialog({required bool isOnline}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ICON
              Icon(
                isOnline ? Icons.check_circle : Icons.cloud_off,
                size: 40,
                color: isOnline ? Colors.green : Colors.orange,
              ),

              const SizedBox(height: 10),

              /// TITLE
              Text(
                isOnline ? "Order placed" : "Saved offline",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              /// SUBTEXT
              Text(
                isOnline
                    ? "Synced successfully"
                    : "Will sync when online",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // dialog
                    Get.back(); // screen
                    Get.back(); // screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isOnline ? Colors.green : Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}