import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../auth/login_page.dart';
import '../navigation/bottom_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    // 🎬 Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // 🔐 CHECK LOGIN
    Timer(const Duration(seconds: 2), () async {
      await _checkLogin();
    });
  }

  Future<void> _checkLogin() async {
    final isLoggedIn = await authController.checkLoginStatus();

    // ✅ EXTRA SAFETY: Firebase user also exists
    final firebaseUser = authController.currentShopId;

    if (isLoggedIn && firebaseUser != null) {
      // 🔥 Load user data before navigation
      await authController.loadUserData();

      Get.offAll(() => const BottomNavigation());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🔥 LOGO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 60,
                  color: primary,
                ),
              ),

              const SizedBox(height: 20),

              // 🏷 APP NAME
              Text(
                "Surat Store",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Smart Inventory",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              CircularProgressIndicator(color: primary),
            ],
          ),
        ),
      ),
    );
  }
}