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
      version: 3,

      onCreate: (db, version) async {
        await _createTables(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {

        // 🔥 VERSION 2 UPDATE
        if (oldVersion < 2) {
          if (!await _columnExists(db, "products", "description")) {
            await db.execute(
                "ALTER TABLE products ADD COLUMN description TEXT DEFAULT ''");
          }
        }

        // 🔥 VERSION 3 UPDATE
        if (oldVersion < 3) {
          if (!await _columnExists(db, "products", "doc_id")) {
            await db.execute(
                "ALTER TABLE products ADD COLUMN doc_id TEXT");
          }
        }
      },
    );
  }

  // 🔍 CHECK COLUMN EXISTS (IMPORTANT)
  Future<bool> _columnExists(
      Database db, String table, String column) async {
    final result = await db.rawQuery("PRAGMA table_info($table)");
    return result.any((col) => col['name'] == column);
  }

  Future<void> _createTables(Database db) async {

    await db.execute('''
      CREATE TABLE products(
        p_id INTEGER PRIMARY KEY AUTOINCREMENT,
        doc_id TEXT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock_qty INTEGER NOT NULL,
        image_path TEXT,
        description TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE orders(
        o_id TEXT PRIMARY KEY,
        customer_name TEXT,
        total_amount REAL,
        order_date TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items(
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT,
        product_id INTEGER,
        qty_sold INTEGER,
        price_at_sale REAL
      )
    ''');
  }
}