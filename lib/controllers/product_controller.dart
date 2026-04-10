import 'package:get/get.dart';
import '../core/db/db_helper.dart';
import '../data/models/product_model.dart';

class ProductController extends GetxController {
  final dbHelper = DBHelper();

  RxList<ProductModel> products = <ProductModel>[].obs;

  @override
  void onInit() {
    loadProducts();
    super.onInit();
  }

  Future<void> loadProducts() async {
    final db = await dbHelper.db;
    final result = await db.query('products');

    products.value =
        result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    final db = await dbHelper.db;

    await db.insert('products', product.toMap());

    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    final db = await dbHelper.db;

    await db.delete('products', where: 'p_id = ?', whereArgs: [id]);

    await loadProducts();
  }
}