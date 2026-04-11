import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../core/db/db_helper.dart';
import '../data/models/product_model.dart';

class ProductController extends GetxController {
  final dbHelper = DBHelper();

  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  RxString searchQuery = ''.obs;
  RxDouble maxPrice = 0.0.obs;
  RxString sortType = 'none'.obs;
  RxBool onlyInStock = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

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

  void applyFilters() {
    List<ProductModel> temp = List.from(products);

    if (searchQuery.value.isNotEmpty) {
      temp = temp.where((p) =>
          p.name.toLowerCase().contains(
              searchQuery.value.toLowerCase())).toList();
    }

    if (maxPrice.value > 0) {
      temp = temp.where((p) => p.price <= maxPrice.value).toList();
    }

    if (onlyInStock.value) {
      temp = temp.where((p) => p.stockQty > 0).toList();
    }

    if (sortType.value == 'low_high') {
      temp.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType.value == 'high_low') {
      temp.sort((a, b) => b.price.compareTo(a.price));
    }

    filteredProducts.value = temp;
  }

  // ➕ ADD PRODUCT (WITH DEBUG)
  Future<void> addProduct(ProductModel product) async {
    final db = await dbHelper.db;

    try {
      final id = await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("✅ Product inserted ID: $id");

      await loadProducts();
    } catch (e) {
      print("❌ ERROR INSERT: $e");
    }
  }

  Future<void> deleteProduct(int id) async {
    final db = await dbHelper.db;

    await db.delete(
      'products',
      where: 'p_id = ?',
      whereArgs: [id],
    );

    await loadProducts();
  }

  // FILTER HELPERS
  void updateSearch(String v) {
    searchQuery.value = v;
    applyFilters();
  }

  void updatePrice(double v) {
    maxPrice.value = v;
    applyFilters();
  }

  void updateSort(String v) {
    sortType.value = v;
    applyFilters();
  }

  void toggleStock(bool v) {
    onlyInStock.value = v;
    applyFilters();
  }

  void resetFilters() {
    searchQuery.value = '';
    maxPrice.value = 0;
    sortType.value = 'none';
    onlyInStock.value = false;
    applyFilters();
  }
}