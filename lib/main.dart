import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:surat_store/ui/screens/splash/splash_page.dart';

import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // ✅ INIT CONTROLLERS (ONLY ONCE)
  Get.put(ProductController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(OrderController());
  Get.put(CartController());


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Surat Store',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true, // 🔥 MODERN UI
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),

      // 🔥 START FROM SPLASH
      home: const SplashScreen(),
    );
  }
}