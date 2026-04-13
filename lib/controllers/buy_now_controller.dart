import 'package:get/get.dart';
import '../data/models/product_model.dart';

class BuyNowController extends GetxController {
  Rx<ProductModel?> product = Rx<ProductModel?>(null);
  RxInt quantity = 1.obs;

  void setProduct(ProductModel p) {
    product.value = p;
    quantity.value = 1;
  }

  void increaseQty() {
    if (quantity.value < (product.value?.stockQty ?? 1)) {
      quantity.value++;
    }
  }

  void decreaseQty() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  double get total =>
      (product.value?.price ?? 0) * quantity.value;

  double get gst => total * 0.05;

  double get grandTotal => total + gst;
}