import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../core/db/db_helper.dart';
import '../core/services/firestore_service.dart';
import '../core/services/sync_manager.dart';
import '../data/models/product_model.dart';
import 'auth_controller.dart';

class ProductController extends GetxController {
  final dbHelper = DBHelper();

  /// 📦 DATA
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  /// 🔍 FILTER STATE
  RxString searchQuery = ''.obs;
  RxDouble maxPrice = 0.0.obs;
  RxString sortType = 'none'.obs;
  RxBool onlyInStock = false.obs;

  /// 🔄 LOADING
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    loadProducts();

    /// 🔥 AUTO FILTER
    everAll([
      products,
      searchQuery,
      maxPrice,
      sortType,
      onlyInStock
    ], (_) => applyFilters());
  }

  // ===========================
  // 📦 LOAD PRODUCTS
  // ===========================
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;

      final db = await dbHelper.db;
      final userId = AuthController.to.currentShopId;

      if (userId == null) return;

      final result = await db.query(
        'products',
        where: 'shop_id = ?',
        whereArgs: [userId],
        orderBy: 'p_id DESC',
      );

      products.value =
          result.map((e) => ProductModel.fromMap(e)).toList();

      applyFilters();

    } catch (e) {
      print("❌ LOAD ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================
  // ➕ ADD PRODUCT
  // ===========================
  Future<void> addProduct(ProductModel product) async {
    try {
      final db = await dbHelper.db;
      final userId = AuthController.to.currentShopId;

      if (userId == null) return;

      final id = await db.insert(
        'products',
        {
          ...product.toMap(),
          'shop_id': userId,
          'is_synced': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final newProduct = product.copyWith(
        pId: id,
        shopId: userId,
        isSynced: 0,
      );

      products.insert(0, newProduct);

      applyFilters();

      /// 🔄 AUTO SYNC
      SyncManager().scheduleSync();

    } catch (e) {
      print("❌ ADD ERROR: $e");
    }
  }

  // ===========================
  // ✏️ UPDATE PRODUCT (🔥 FIXED)
  // ===========================
  Future<void> updateProduct(ProductModel product) async {
    try {
      if (product.pId == null) return;

      final db = await dbHelper.db;

      /// 🔥 KEEP doc_id (VERY IMPORTANT)
      final updatedProduct = product.copyWith(
        isSynced: 0,
      );

      await db.update(
        'products',
        updatedProduct.toMap(),
        where: 'p_id = ?',
        whereArgs: [product.pId],
      );

      /// 🔥 UPDATE UI SAFELY
      final index =
      products.indexWhere((p) => p.pId == product.pId);

      if (index != -1) {
        products[index] = updatedProduct;
        products.refresh(); // 🔥 FORCE UI UPDATE
      }

      applyFilters();

      /// 🔄 AUTO SYNC
      SyncManager().scheduleSync();

      print("✏️ Product updated: ${product.pId}");

    } catch (e) {
      print("❌ UPDATE ERROR: $e");
    }
  }

  // ===========================
  // ❌ DELETE PRODUCT
  // ===========================
  Future<void> deleteProduct(ProductModel product) async {
    try {
      final db = await dbHelper.db;
      final userId = AuthController.to.currentShopId;

      if (product.pId == null || userId == null) return;

      /// 🔥 ALWAYS GENERATE DOC ID
      final docId = product.docId != null && product.docId!.isNotEmpty
          ? product.docId!
          : product.pId.toString(); // 🔥 fallback

      /// 🔥 DELETE FROM FIRESTORE (IMPORTANT)
      await FirestoreService().deleteProduct(userId, docId);

      /// 🔥 DELETE FROM LOCAL
      await db.delete(
        'products',
        where: 'p_id = ?',
        whereArgs: [product.pId],
      );

      /// 🔥 REMOVE FROM UI
      products.removeWhere((p) => p.pId == product.pId);

      applyFilters();

      print("🗑️ Fully deleted: ${product.pId}");

    } catch (e) {
      print("❌ DELETE ERROR: $e");
    }
  }

  // ===========================
  // 🔍 FILTER LOGIC
  // ===========================
  void applyFilters() {
    List<ProductModel> temp = List.from(products);

    /// 🔍 SEARCH
    if (searchQuery.value.isNotEmpty) {
      temp = temp.where((p) =>
          p.name.toLowerCase().contains(
              searchQuery.value.toLowerCase())).toList();
    }

    /// 💰 PRICE
    if (maxPrice.value > 0) {
      temp = temp.where((p) => p.price <= maxPrice.value).toList();
    }

    /// 📦 STOCK
    if (onlyInStock.value) {
      temp = temp.where((p) => p.stockQty > 0).toList();
    }

    /// 🔽 SORT
    switch (sortType.value) {
      case 'low_high':
        temp.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'high_low':
        temp.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        temp.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    filteredProducts.value = temp;
  }

  // ===========================
  // 🎛 FILTER CONTROLS
  // ===========================
  void updateSearch(String value) => searchQuery.value = value;

  void updatePrice(double value) => maxPrice.value = value;

  void updateSort(String value) => sortType.value = value;

  void toggleStock(bool value) => onlyInStock.value = value;

  void resetFilters() {
    searchQuery.value = '';
    maxPrice.value = 0;
    sortType.value = 'none';
    onlyInStock.value = false;
  }
}