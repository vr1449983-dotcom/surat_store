import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../core/db/db_helper.dart';
import '../data/models/product_model.dart';

class ProductController extends GetxController {
  final dbHelper = DBHelper();

  // 📦 ALL PRODUCTS
  RxList<ProductModel> products = <ProductModel>[].obs;

  // 🎯 FILTERED PRODUCTS
  RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  // 🔍 SEARCH
  RxString searchQuery = ''.obs;

  // 💰 PRICE FILTER
  RxDouble maxPrice = 0.0.obs;

  // 🔃 SORT TYPE
  RxString sortType = 'none'.obs;
  // values: none, low_high, high_low

  // 📦 STOCK FILTER
  RxBool onlyInStock = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // 📦 LOAD PRODUCTS FROM DB
  Future<void> loadProducts() async {
    final db = await dbHelper.db;

    final result = await db.query(
      'products',
      orderBy: 'p_id DESC',
    );

    products.value =
        result.map((e) => ProductModel.fromMap(e)).toList();

    applyFilters();
  }

  // 🔥 APPLY ALL FILTERS
  void applyFilters() {
    List<ProductModel> temp = List.from(products);

    // 🔍 SEARCH
    if (searchQuery.value.isNotEmpty) {
      temp = temp.where((product) {
        return product.name
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // 💰 PRICE FILTER
    if (maxPrice.value > 0) {
      temp = temp.where((product) {
        return product.price <= maxPrice.value;
      }).toList();
    }

    // 📦 STOCK FILTER
    if (onlyInStock.value) {
      temp = temp.where((product) {
        return product.stockQty > 0;
      }).toList();
    }

    // 🔃 SORTING
    if (sortType.value == 'low_high') {
      temp.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType.value == 'high_low') {
      temp.sort((a, b) => b.price.compareTo(a.price));
    }

    // ✅ UPDATE FILTERED LIST
    filteredProducts.value = temp;
  }

  // 🔍 UPDATE SEARCH
  void updateSearch(String value) {
    searchQuery.value = value;
    applyFilters();
  }

  // 💰 UPDATE PRICE
  void updatePrice(double value) {
    maxPrice.value = value;
    applyFilters();
  }

  // 🔃 UPDATE SORT
  void updateSort(String value) {
    sortType.value = value;
    applyFilters();
  }

  // 📦 TOGGLE STOCK
  void toggleStock(bool value) {
    onlyInStock.value = value;
    applyFilters();
  }

  // 🔄 RESET ALL FILTERS
  void resetFilters() {
    searchQuery.value = '';
    maxPrice.value = 0.0;
    sortType.value = 'none';
    onlyInStock.value = false;

    applyFilters();
  }

  // ➕ ADD PRODUCT
  Future<void> addProduct(ProductModel product) async {
    final db = await dbHelper.db;

    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await loadProducts();
  }

  // ❌ DELETE PRODUCT
  Future<void> deleteProduct(int id) async {
    final db = await dbHelper.db;

    await db.delete(
      'products',
      where: 'p_id = ?',
      whereArgs: [id],
    );

    await loadProducts();
  }

}