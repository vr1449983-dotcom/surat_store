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
      version: 9, // 🔥 UPDATED VERSION

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
              is_synced INTEGER DEFAULT 0,
              is_deleted INTEGER DEFAULT 0
            )
          ''');

          await db.execute('''
            INSERT OR REPLACE INTO products_new
            SELECT *, 0 FROM products
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
              is_synced INTEGER DEFAULT 0,
              UNIQUE(shop_id, product_id)
            )
          ''');
        }

        // =========================
        // ➕ ADD is_deleted COLUMN
        // =========================
        if (oldVersion < 8) {
          await db.execute(
              "ALTER TABLE products ADD COLUMN is_deleted INTEGER DEFAULT 0");
        }

        // =========================
        // ➕ ADD cart is_synced
        // =========================
        if (oldVersion < 9) {
          await db.execute(
              "ALTER TABLE cart ADD COLUMN is_synced INTEGER DEFAULT 0");
        }

        // =========================
        // ⚡ INDEXES
        // =========================
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_products_shop
          ON products(shop_id)
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_cart_shop
          ON cart(shop_id)
        ''');
      },
    );
  }

  // =========================
  // 🏗 CREATE TABLES
  // =========================
  Future<void> _createTables(Database db) async {

    // =========================
    // 📦 PRODUCTS
    // =========================
    await db.execute('''
      CREATE TABLE products(
        p_id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id TEXT,
        doc_id TEXT UNIQUE,
        name TEXT,
        price REAL,
        stock_qty INTEGER,
        image_path TEXT,
        description TEXT,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    // =========================
    // 📦 ORDERS
    // =========================
    await db.execute('''
      CREATE TABLE orders(
        o_id TEXT PRIMARY KEY,
        shop_id TEXT,
        total_amount REAL,
        order_date TEXT,
        customer_name TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // =========================
    // 📦 ORDER ITEMS
    // =========================
    await db.execute('''
      CREATE TABLE order_items(
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id TEXT,
        order_id TEXT,
        product_id INTEGER,
        qty_sold INTEGER,
        price_at_sale REAL
      )
    ''');

    // =========================
    // 🛒 CART
    // =========================
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id TEXT,
        product_id INTEGER,
        quantity INTEGER,
        is_synced INTEGER DEFAULT 0,
        UNIQUE(shop_id, product_id)
      )
    ''');

    // =========================
    // ⚡ INDEXES
    // =========================
    await db.execute('''
      CREATE INDEX idx_products_shop ON products(shop_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_cart_shop ON cart(shop_id)
    ''');
  }

}