import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/cart_card.dart';

class CartController extends GetxController {
  var cartItems = <ProductModel, int>{}.obs;

  void addToCart(ProductModel product) {
    if (cartItems.containsKey(product)) {
      cartItems[product] = cartItems[product]! + 1;
    } else {
      cartItems[product] = 1;
    }
    cartItems.refresh();
  }

  void increase(ProductModel product) {
    cartItems[product] = cartItems[product]! + 1;
    cartItems.refresh();
  }

  void decrease(ProductModel product) {
    if (cartItems[product]! > 1) {
      cartItems[product] = cartItems[product]! - 1;
    } else {
      cartItems.remove(product);
    }
    cartItems.refresh();
  }

  double get total => cartItems.entries
      .fold(0, (sum, e) => sum + (e.key.price * e.value));

  double get gst => total * 0.05;
}class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return Obx(() => Column(
      children: [
        Expanded(
          child: ListView(
            children: controller.cartItems.entries.map((e) {
              return CartCard(
                product: e.key,
                quantity: e.value,
                onIncrease: () => controller.increase(e.key),
                onDecrease: () => controller.decrease(e.key),
              );
            }).toList(),
          ),
        ),

        Text("Total: ₹${controller.total}"),
        Text("GST (5%): ₹${controller.gst}"),

        ElevatedButton(
          onPressed: () {

          },
          child: const Text("Proceed to Buy"),
        )
      ],
    ));
  }
}