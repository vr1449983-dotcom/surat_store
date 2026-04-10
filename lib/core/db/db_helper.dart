import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'surat_store.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // PRODUCTS
        await db.execute('''
        CREATE TABLE products(
          p_id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          stock_qty INTEGER,
          image_path TEXT,
          is_synced INTEGER
        )
        ''');

        // ORDERS
        await db.execute('''
        CREATE TABLE orders(
          o_id TEXT PRIMARY KEY,
          customer_name TEXT,
          total_amount REAL,
          order_date TEXT,
          is_synced INTEGER
        )
        ''');

        // ORDER ITEMS
        await db.execute('''
        CREATE TABLE order_items(
          item_id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id TEXT,
          product_id INTEGER,
          qty_sold INTEGER,
          price_at_sale REAL
        )
        ''');
      },
    );
  }
}