import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';
import 'core/services/sync_manager.dart';
import 'ui/screens/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ STEP 1: Firebase FIRST
  await Firebase.initializeApp();

  /// ✅ STEP 2: Controllers
  Get.put(ProductController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(OrderController(), permanent: true);
  Get.put(CartController(), permanent: true);

  /// ✅ STEP 3: Sync AFTER Firebase
  final syncManager = SyncManager();
  syncManager.startListening();   // internet listener
  syncManager.scheduleSync();    // initial sync

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