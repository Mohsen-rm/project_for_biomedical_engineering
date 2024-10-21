import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelperSites {
  static final DbHelperSites _instance = DbHelperSites._internal();
  static Database? _database;

  DbHelperSites._internal();

  factory DbHelperSites() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'locations.db');
    return await openDatabase(
      path,
      version: 2, // زيادة رقم الإصدار عند تعديل الجداول
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute('DROP TABLE IF EXISTS items');
          await db.execute('DROP TABLE IF EXISTS locations');
          await _createTables(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        details TEXT,
        qr_code TEXT,
        location_id INTEGER NOT NULL,
        FOREIGN KEY (location_id) REFERENCES locations (id) ON DELETE CASCADE
      )
    ''');
  }

  // ========== الدوال الخاصة بالمواقع ==========

  Future<int> insertLocation(Map<String, dynamic> location) async {
    final db = await database;
    return await db.insert('locations', location);
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await database;
    return await db.query('locations');
  }

  Future<int> updateLocation(Map<String, dynamic> location) async {
    final db = await database;
    return await db.update(
      'locations',
      location,
      where: 'id = ?',
      whereArgs: [location['id']],
    );
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    return await db.delete(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== الدوال الخاصة بالأشياء ==========

  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> getItemsByLocation(int locationId) async {
    final db = await database;
    return await db.query(
      'items',
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
  }

  Future<int> updateItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.update(
      'items',
      item,
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getItemByQRCode(String qrCode) async {
    final db = await database;
    final result = await db.query(
      'items',
      where: 'qr_code = ?',
      whereArgs: [qrCode],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

}
