import 'package:get/get.dart';
import '../data/models/product_model.dart';

class CartController extends GetxController {
  var cartItems = <ProductModel, int>{}.obs;

  // ===========================
  // ➕ ADD TO CART (WITH STOCK CHECK)
  // ===========================
  void addToCart(ProductModel product) {
    final currentQty = cartItems[product] ?? 0;

    if (currentQty >= product.stockQty) {
      Get.snackbar("Stock Limit", "No more stock available");
      return;
    }

    cartItems[product] = currentQty + 1;
    cartItems.refresh();
  }

  // ===========================
  // ➕ INCREASE
  // ===========================
  void increase(ProductModel product) {
    final currentQty = cartItems[product] ?? 0;

    if (currentQty >= product.stockQty) {
      Get.snackbar("Limit Reached", "Max stock reached");
      return;
    }

    cartItems[product] = currentQty + 1;
    cartItems.refresh();
  }

  // ===========================
  // ➖ DECREASE
  // ===========================
  void decrease(ProductModel product) {
    final currentQty = cartItems[product] ?? 0;

    if (currentQty <= 1) return; // ❌ never below 1

    cartItems[product] = currentQty - 1;
    cartItems.refresh();
  }

  // ===========================
  // 💰 TOTAL
  // ===========================
  double get total => cartItems.entries.fold(
      0, (sum, e) => sum + (e.key.price * e.value));

  double get gst => total * 0.05;

  double get grandTotal => total + gst;
}