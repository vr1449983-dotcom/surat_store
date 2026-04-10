import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


import '../data/models/product_model.dart';

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
}