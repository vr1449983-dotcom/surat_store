import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../core/services/sync_manager.dart';
import '../core/services/sync_service.dart';

import '../ui/screens/auth/login_page.dart';
import '../ui/screens/auth/register_page.dart';
import '../ui/screens/navigation/bottom_navigation.dart';

import 'cart_controller.dart';
import 'order_controller.dart';
import 'product_controller.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();


  // ================= DEPENDENCIES =================
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= STATE =================
  final isLoading = false.obs;

  final prefillEmail = ''.obs;
  final prefillPassword = ''.obs;

  final userName = ''.obs;
  final userEmail = ''.obs;

  String? get currentShopId => _auth.currentUser?.uid;

  // ================= REGISTER =================
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final shopId = userCredential.user!.uid;

      await _createUserInFirestore(
        shopId: shopId,
        name: name,
        email: email,
      );

      await _saveLoginSession(shopId);

      await _afterLoginSetup(); // 🔥 IMPORTANT

      _clearPrefill();
      _navigateToHome();

      _showSuccess("Account created successfully");
    } on FirebaseAuthException catch (e) {
      _handleRegisterError(e);
    } finally {
      _setLoading(false);
    }
  }

  // ================= LOGIN =================
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      final exists = await _checkUserExists(email);

      if (!exists) {
        _handleUserNotFound(email, password);
        return;
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveLoginSession(userCredential.user!.uid);

      await _afterLoginSetup(); // 🔥 IMPORTANT

      _navigateToHome();

      _showSuccess("Login successful");
    } on FirebaseAuthException catch (e) {
      _handleLoginError(e);
    } finally {
      _setLoading(false);
    }
  }

  // ================= 🔥 AFTER LOGIN CORE =================
  Future<void> _afterLoginSetup() async {
    try {
      // =========================
      // 👤 LOAD USER DATA
      // =========================
      await loadUserData();

      // =========================
      // ☁️ DOWNLOAD USER DATA (ONCE)
      // =========================
      await SyncService().downloadAllUserData();

      // =========================
      // 🔄 START REALTIME SYNC
      // =========================
      SyncService().startRealtimeSync();

      // =========================
      // 📦 LOAD PRODUCTS FIRST (VERY IMPORTANT)
      // =========================
      if (Get.isRegistered<ProductController>()) {
        await Get.find<ProductController>().loadProducts();
      } else {
        print("⚠️ ProductController not registered");
      }

      // =========================
      // 🛒 LOAD CART AFTER PRODUCTS
      // =========================
      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().loadCart();
      } else {
        print("⚠️ CartController not registered");
      }

      // =========================
      // 📦 START ORDER LISTENER (OPTIONAL BUT GOOD)
      // =========================
      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().startListeningOrders();
      }

      // =========================
      // 🌐 AUTO SYNC MANAGER
      // =========================
      SyncManager().startListening();

      print("✅ User environment ready (Products + Cart + Sync loaded)");
    } catch (e) {
      print("❌ Setup Error: $e");
    }
  }
  // ================= 🔥 CLEAR LOCAL DB =================
  Future<void> _clearLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUser = prefs.getString('last_user_id');

    if (lastUser != currentShopId) {
      print("🧹 Clearing old user data...");

      final db = await openDatabase('surat_store.db');

      await db.delete('products');
      await db.delete('orders');
      await db.delete('order_items');

      await prefs.setString('last_user_id', currentShopId!);
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _clearOrderData();

    await _auth.signOut();
    await _clearSession();

    _resetUserState();

    Get.offAll(() => const LoginScreen());

    Get.snackbar("Logout", "Logged out successfully",
        snackPosition: SnackPosition.TOP);
  }

  // ================= SESSION =================
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> _saveLoginSession(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('shop_id', shopId);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ================= FIRESTORE =================
  Future<void> _createUserInFirestore({
    required String shopId,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(shopId).set({
      'shop_id': shopId,
      'name': name,
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> _checkUserExists(String email) async {
    final result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  // ================= USER DATA =================
  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      userName.value = doc['name'] ?? '';
      userEmail.value = doc['email'] ?? '';
    }
  }

  // ================= HELPERS =================
  void _setLoading(bool value) => isLoading.value = value;

  void _clearPrefill() {
    prefillEmail.value = '';
    prefillPassword.value = '';
  }

  void _resetUserState() {
    userName.value = '';
    userEmail.value = '';
  }

  void _navigateToHome() {
    Get.offAll(() => const BottomNavigation());
  }

  void _startOrderListener() {
    if (Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().startListeningOrders();
    }
  }

  void _clearOrderData() {
    if (Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().clearOrders();
    }
  }

  void _handleUserNotFound(String email, String password) {
    Get.snackbar("Account Not Found", "Please create a new account");
    prefillEmail.value = email;
    prefillPassword.value = password;
    Get.to(() => const RegisterScreen());
  }

  void _handleRegisterError(FirebaseAuthException e) {
    Get.snackbar("Register Failed", e.message ?? "Error");
  }

  void _handleLoginError(FirebaseAuthException e) {
    Get.snackbar("Login Failed", e.message ?? "Error");
  }

  void _showSuccess(String message) {
    Get.snackbar("Success", message);
  }
  Future<void> updateUserName(String newName) async {
    final userId = currentShopId;
    if (userId == null) return;

    userName.value = newName;

    /// 🔥 UPDATE FIRESTORE
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
      'name': newName,
    }, SetOptions(merge: true));

    /// 🔥 UPDATE LOCAL (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
  }
}