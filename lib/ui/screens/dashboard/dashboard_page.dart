import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../controllers/product_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../products/add_product_page.dart';
import 'inventory_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final userId = AuthController.to.currentShopId;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /// ===========================
      /// 🎨 MODERN APPBAR
      /// ===========================
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadProducts(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// ===========================
                /// 📊 STATS
                /// ===========================
                Row(
                  children: [
                    _statCard(
                      "Products",
                      controller.products.length.toString(),
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      "Stock",
                      controller.products.fold(
                          0, (sum, p) => sum + p.stockQty).toString(),
                      Icons.storage,
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// ===========================
                /// 📈 REALTIME SALES GRAPH
                /// ===========================
                if (userId != null)
                  _salesGraph(userId),

                const SizedBox(height: 20),

                /// ===========================
                /// 🔥 ACTIONS
                /// ===========================
                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        "Add Product",
                        Icons.add_box,
                        Colors.deepPurple,
                            () => Get.to(() => const AddProductScreen()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionCard(
                        "Inventory",
                        Icons.inventory,
                        Colors.orange,
                            () => Get.to(() => InventoryScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// ===========================
  /// 📈 SALES GRAPH (REALTIME 🔥)
  /// ===========================
  Widget _salesGraph(String userId) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          /// 🔥 GROUP BY LAST 7 DAYS
          Map<int, double> weekly = {
            0: 0,1: 0,2: 0,3: 0,4: 0,5: 0,6: 0
          };

          for (var d in docs) {
            final date = DateTime.tryParse(d['order_date'] ?? '');
            final amount = (d['total_amount'] ?? 0).toDouble();

            if (date != null) {
              weekly[date.weekday % 7] =
                  (weekly[date.weekday % 7] ?? 0) + amount;
            }
          }

          final spots = weekly.entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weekly Sales",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),

                    borderData: FlBorderData(show: false),

                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ===========================
  /// 📊 STAT CARD
  /// ===========================
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }

  /// ===========================
  /// 🔥 ACTION CARD
  /// ===========================
  Widget _actionCard(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}