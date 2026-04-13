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
      version: 6, // 🔥 UPDATED

      onCreate: (db, version) async {
        await _createTables(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {

        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE products_new(
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

        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE cart(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              shop_id TEXT,
              product_id INTEGER,
              quantity INTEGER,
              UNIQUE(shop_id, product_id) -- 🔥 prevent duplicate cart rows
            )
          ''');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {

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
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE orders(
        o_id TEXT PRIMARY KEY,
        shop_id TEXT,
        total_amount REAL,
        order_date TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

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

    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id TEXT,
        product_id INTEGER,
        quantity INTEGER,
        UNIQUE(shop_id, product_id)
      )
    ''');
  }
}