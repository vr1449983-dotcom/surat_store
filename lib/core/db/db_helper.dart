import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'surat_store.db');

    return await openDatabase(
      path,
      version: 7, // 🔥 bumped version

      onCreate: (db, version) async {
        await _createTables(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {

        // =========================
        // 🔄 PRODUCTS MIGRATION
        // =========================
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS products_new(
              p_id INTEGER PRIMARY KEY AUTOINCREMENT,
              shop_id TEXT,
              doc_id TEXT UNIQUE,
              name TEXT,
              price REAL,
              stock_qty INTEGER,
              image_path TEXT,
              description TEXT,
              is_synced INTEGER DEFAULT 0
            )
          ''');

          await db.execute('''
            INSERT OR REPLACE INTO products_new
            SELECT * FROM products
          ''');

          await db.execute('DROP TABLE products');
          await db.execute('ALTER TABLE products_new RENAME TO products');
        }

        // =========================
        // 🛒 CART TABLE FIX
        // =========================
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cart(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              shop_id TEXT,
              product_id INTEGER,
              quantity INTEGER,
              UNIQUE(shop_id, product_id)
            )
          ''');
        }

        // =========================
        // ⚡ INDEXES (NEW)
        // =========================
        if (oldVersion < 7) {
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_cart_shop
            ON cart(shop_id)
          ''');
        }
      },
    );
  }

  // =========================
  // 🏗 CREATE ALL TABLES
  // =========================
  Future<void> _createTables(Database db) async {

    // =========================
    // 📦 PRODUCTS
    // =========================
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products(
        p_id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id TEXT,
        doc_id TEXT UNIQUE,
        name TEXT,
        price REAL,
        stock_qty INTEGER,
        image_path TEXT,
        description TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // =========================
    // 📦 ORDERS
    // =========================
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders(
        o_id TEXT PRIMARY KEY,
        shop_id TEXT, -- 🔥 IMPORTANT
        total_amount REAL,
        order_date TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // =========================
    // 📦 ORDER ITEMS
    // =========================
    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_items(
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id TEXT, -- 🔥 IMPORTANT
        order_id TEXT,
        product_id INTEGER,
        qty_sold INTEGER,
        price_at_sale REAL
      )
    ''');

    // =========================
    // 🛒 CART (USER BASED)
    // =========================
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id TEXT,
        product_id INTEGER,
        quantity INTEGER,
        UNIQUE(shop_id, product_id)
      )
    ''');

    // =========================
    // ⚡ INDEX (PERFORMANCE)
    // =========================
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_cart_shop
      ON cart(shop_id)
    ''');
  }
}