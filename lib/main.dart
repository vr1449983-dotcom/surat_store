import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'controllers/auth_controller.dart';
import 'controllers/order_controller.dart';
import 'ui/screens/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ REQUIRED

  await Firebase.initializeApp(); // ✅ MUST

  // ✅ INIT CONTROLLERS ONCE
  Get.put(AuthController(), permanent: true);
  Get.put(OrderController());

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
        colorScheme: ColorScheme.fromSeed( // ✅ FIXED
          seedColor: Colors.deepPurple,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}