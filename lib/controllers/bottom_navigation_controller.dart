import 'package:get/get.dart';
import 'package:surat_store/ui/screens/home/home_page.dart';
import 'package:surat_store/ui/screens/profile/profile_page.dart';

import '../ui/screens/cart/cart_page.dart';
import '../ui/screens/dashboard/dashboard_page.dart';
import '../ui/screens/order/order_page.dart';

class BottomNavController extends GetxController {
  var currentIndex = 0.obs;

  final pages = [
    const HomePage(),
     DashboardScreen(),
    const CartScreen(),
    const OrderScreen(),
    const ProfileScreen(),
  ];

  void changeTab(int index) {
    currentIndex.value = index;
  }
}